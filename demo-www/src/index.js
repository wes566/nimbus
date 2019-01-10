//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import {createElement, register} from 'lwc';
import {registerWireService} from 'wire-service';
import App from 'nimbus/app';

import nimbus from 'nimbus';

registerWireService(register);

const container = document.getElementById('app');
const element = createElement('nimbus-app', {is: App});

container.appendChild(element);
