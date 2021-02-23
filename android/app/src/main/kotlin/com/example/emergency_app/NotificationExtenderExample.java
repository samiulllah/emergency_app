package com.mattperiera.emergencyapp;

import com.onesignal.OSNotificationDisplayedResult;
import com.onesignal.OSNotificationPayload;
import com.onesignal.NotificationExtenderService;
import com.onesignal.OSNotificationReceivedResult;
import java.math.BigInteger;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import static android.webkit.ConsoleMessage.MessageLevel.LOG;

public class NotificationExtenderExample extends NotificationExtenderService {
    @Override
    protected boolean onNotificationProcessing(OSNotificationReceivedResult receivedResult) {
        OverrideSettings overrideSettings = new OverrideSettings();
        overrideSettings.extender = new NotificationCompat.Extender() {


            @Override
            public NotificationCompat.Builder extend(NotificationCompat.Builder builder) {
                //Force remove push from Notification Center after 30 seconds
//                builder.setTimeoutAfter(30000);
                // Sets the icon accent color notification color to Green on Android 5.0+ devices.

                builder.setColor(new BigInteger("FFed2202", 16).intValue());
                builder.setContentTitle(receivedResult.payload.title);
                builder.setContentText(receivedResult.payload.body);
                builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC);
                return builder;
            }
        };

        OSNotificationDisplayedResult displayedResult = displayNotification(overrideSettings);
        try {

            String url = receivedResult.payload.additionalData.getString("clipUrl");
            Intent serviceIntent = new Intent(this, MyBroadcastReceiver.class);
            serviceIntent.putExtra("title", receivedResult.payload.title);
            serviceIntent.putExtra("body", receivedResult.payload.body);
            serviceIntent.putExtra("url", url);
            MyBroadcastReceiver.enqueueWork(this, serviceIntent);

        }catch(Exception e){

        }
        
        return false;
    }

}
