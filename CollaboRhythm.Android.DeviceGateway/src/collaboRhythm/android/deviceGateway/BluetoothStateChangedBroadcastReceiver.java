/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.android.deviceGateway;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class BluetoothStateChangedBroadcastReceiver extends BroadcastReceiver {

	private static final String CLASS = "BluetoothStateChangedBroadcastReceiver";
	
	private final static Logger log = LoggerFactory.getLogger();
	
	@Override
	public void onReceive(Context context, Intent intent) {
		Bundle extras = intent.getExtras();
		int state = extras.getInt(BluetoothAdapter.EXTRA_STATE);
		String stateString = new String();
		switch (state) {
		case BluetoothAdapter.STATE_OFF:
			stateString = "STATE_OFF";
			sendBluetoothStateChangedIntent(context, extras);
			break;
		case BluetoothAdapter.STATE_ON:
			stateString = "STATE_ON";
			sendBluetoothStateChangedIntent(context, extras);
			break;
		case BluetoothAdapter.STATE_TURNING_OFF:
			stateString = "STATE_TURNING_OFF";
			break;
		case BluetoothAdapter.STATE_TURNING_ON:
			stateString = "STATE_TURNING_ON";
			break;
		}
		log.debug(CLASS + ": " + stateString);
	}
	
	public void sendBluetoothStateChangedIntent(Context context, Bundle extras) {
		Intent startServiceIntent = new Intent(context, DeviceGatewayService.class);
		startServiceIntent.putExtras(extras);
    	context.startService(startServiceIntent);
	}
}