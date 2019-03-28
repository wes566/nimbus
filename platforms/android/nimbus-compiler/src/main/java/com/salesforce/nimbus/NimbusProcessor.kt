package com.salesforce.nimbus;

import com.squareup.kotlinpoet.*
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.TypeElement
import javax.lang.model.type.TypeKind
import javax.tools.Diagnostic
import kotlin.reflect.jvm.internal.impl.builtins.jvm.JavaToKotlinClassMap


class NimbusProcessor: AbstractProcessor() {

    override fun process(annotations: MutableSet<out TypeElement>?, env: RoundEnvironment): Boolean {

        val bindings = env.getElementsAnnotatedWith(ExtensionMethod::class.java)
                .groupBy { it.enclosingElement }

        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "map? ${JavaToKotlinClassMap.INSTANCE}")

        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "method? ${bindings}")

        bindings.forEach { element, methods ->
            val packageName = processingEnv.elementUtils.getPackageOf(element).qualifiedName.toString()
            val typeName = element.simpleName.toString() + "Binder"

            // the binder needs to capture the bound target to pass through calls to it
            val type = TypeSpec.classBuilder(typeName)
                    .primaryConstructor(FunSpec.constructorBuilder()
                            .addParameter("target", element.asType().asTypeName())
                            .build()
                    )
                    .addProperty(PropertySpec.builder("target", element.asType().asTypeName())
                            .initializer("target")
                            .build())

            methods.forEach {
                val methodElement = it as ExecutableElement


                val methodSpec = FunSpec.builder(it.simpleName.toString())
                        .addAnnotation(AnnotationSpec.builder(ClassName("android.webkit", "JavascriptInterface")).build())

                if (methodElement.returnType.toString().equals("java.lang.String")) {
                    methodSpec.returns(String::class)
                } else {
                    methodSpec.returns(methodElement.returnType.asTypeName())
                }
                val arguments = mutableListOf<String>()
                methodElement.parameters.forEach {
                    processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "arg ${it} ${it.asType()} ${it.asType().kind}")

                    var type = it.asType()
                    if (/*type.toString().startsWith("kotlin.jvm.functions.Function") || */
                            type.toString().equals("java.lang.String")) {
                        // callbacks functions are mapped through as a callbackId string
                        methodSpec.addParameter(it.simpleName.toString(), String::class)
                    } else {
                        methodSpec.addParameter(it.simpleName.toString(), it.asType().asTypeName())
                    }
                    arguments.add(it.simpleName.toString())
                }

                // TODO: method body
//                val hasReturn = it.returnType.kind != TypeKind.VOID
//                methodSpec.addStatement("$hasReturn")
                methodSpec.addCode("""
                    return target.${it.simpleName}(${arguments.joinToString(",")})
                """.trimIndent())
                type.addFunction(methodSpec.build())
            }
            val file = FileSpec.builder(packageName, typeName)
                    .addType(type.build())
            file.build().writeTo(processingEnv.filer)
        }

        return true
    }

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(Extension::class.java.canonicalName)
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }
}
