//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.salesforce.k2v8.scope
import io.kotest.property.forAll
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class PrimitiveV8EncodableTests {

    private lateinit var v8: V8

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()
    }

    @After
    fun tearDown() {
        v8.close()
    }

    @Test
    fun testDoubleToV8() = v8.scope {
        runBlocking {
            forAll<Double> { a ->
                // Comparing NaN requires a different way
                // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
                if (a == Double.POSITIVE_INFINITY || a == Double.NEGATIVE_INFINITY || a.equals(Double.NaN as Number)) {
                    var sameExceptionMessage = false
                    try {
                        a.toV8Encodable(v8)
                    } catch (e: Exception) {
                        sameExceptionMessage = e.message.equals("Double value should be finite.")
                    }
                    sameExceptionMessage
                } else {
                    val array = a.toV8Encodable(v8).encode() as V8Array
                    val value = array.getDouble(0)
                    a == value
                }
            }
        }
    }

    @Test
    fun testIntToV8() = v8.scope {
        runBlocking {
            forAll<Int> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getInteger(0)
                a == value
            }
        }
    }

    @Test
    fun testBooleanToV8() = v8.scope {
        runBlocking {
            forAll<Boolean> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getBoolean(0)
                a == value
            }
        }
    }

    @Test
    fun testLongToV8() = v8.scope {
        runBlocking {
            forAll<Long> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getDouble(0)

                // v8 doesn't support long so must convert to double for comparison
                a.toDouble() == value
            }
        }
    }

    @Test
    fun testStringToV8() = v8.scope {
        runBlocking {
            forAll<String> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getString(0)
                a == value
            }
        }
    }
}
