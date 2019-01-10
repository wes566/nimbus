//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import com.salesforce.nimbus.JSONSerializable
import org.json.JSONObject


class UserDefinedType : JSONSerializable {
    val intParam = 5
    val stringParam = "hello user defined type"

    override fun stringify(): String {
        val jsonObject = JSONObject()
        jsonObject.put("intParam", intParam)
        jsonObject.put("stringParam", stringParam)
        return jsonObject.toString()
    }
}
