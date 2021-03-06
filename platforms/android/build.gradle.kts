//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.dokka.gradle.DokkaTask
import org.gradle.api.GradleException

plugins {
    `maven-publish`
    id("org.jetbrains.dokka") version Versions.dokkaGradlePlugin
    id("com.vanniktech.android.junit.jacoco") version Versions.jacocoAndroid
    id("org.jlleitschuh.gradle.ktlint") version Versions.ktlintGradle
    id("org.jetbrains.kotlin.plugin.serialization") version Versions.kotlin
}

allprojects {
    repositories {
        google()
        jcenter()
    }

    group = getSettingValue(PublishingSettingsKey.group) ?: ""
    val versionFile = file("$rootDir/../../lerna.json")
    val parsedFile = org.json.JSONObject(versionFile.readText())
    version = parsedFile.getString("version")

    if (gradle.startParameter.taskNames.contains("publishSnapshot")) {
        val regex = "[0-9]+\\.[0-9]+\\.[0-9]+".toRegex()
        val numericVersion = regex.find(version.toString())
        if (numericVersion != null) {
            version = "${numericVersion.value}-SNAPSHOT"
        } else {
            logger.error("Version in project is invalid")
            throw GradleException("Version in project is invalid")
        }
    }

    tasks.withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}

junitJacoco {
    includeNoLocationClasses = false
    jacocoVersion = Versions.jacoco
    setIgnoreProjects("demo-app")
    includeInstrumentationCoverageInMergedReport = true
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

tasks {
    val dokka by getting(DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/docs"
        subProjects = listOf("core", "core-plugins", "bridge-webview", "bridge-v8")
        configuration {
            moduleName = "nimbus"
        }
    }
}

val publishSnapshot = tasks.register("publishSnapshot") {
    dependsOn(getTasksByName("build", true))
}

subprojects {
    apply(plugin = "org.jlleitschuh.gradle.ktlint")

    ktlint {
        version.set(Versions.ktlint)
    }
    if (path.contains("modules")) {
        tasks.register("publishSnapshot")

        tasks.withType<PublishToMavenRepository>().configureEach {
            doLast {
                logger.lifecycle("Successfully uploaded ${publication.groupId}:${publication.artifactId}:${publication.version} to ${repository.name}")
            }
        }

        tasks.withType<PublishToMavenLocal>().configureEach {
            doLast {
                logger.lifecycle("Successfully uploaded ${publication.groupId}:${publication.artifactId}:${publication.version} to MavenLocal.")
            }
        }
    }
}

apply(from = rootProject.file("gradle/test-output.gradle.kts"))
