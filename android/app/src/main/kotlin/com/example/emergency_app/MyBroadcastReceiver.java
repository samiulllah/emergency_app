package com.mattperiera.emergencyapp;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.JobIntentService;

public class MyBroadcastReceiver extends JobIntentService {
    
    static void enqueueWork(Context context, Intent work) {
        enqueueWork(context, MyBroadcastReceiver.class, 123, work);
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                // write uri to prefs first then launch activity
                SharedPreferences prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
                SharedPreferences.Editor editor=prefs.edit();
                editor.putString("flutter.title",intent.getStringExtra("title"));
                editor.putString("flutter.body",intent.getStringExtra("body"));
                editor.putString("flutter.url",intent.getStringExtra("url"));
                editor.apply();
                // launch activity
                startActivityFromMainThread();
            } // run()
        }).start();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public boolean onStopCurrentWork() {
        return super.onStopCurrentWork();
    }
    public void startActivityFromMainThread(){

        Handler handler = new Handler(Looper.getMainLooper());

        handler.post(new Runnable() {
            @Override
            public void run() {


                Intent intent1 = new Intent(getBaseContext(), MainActivity.class);
                intent1.setAction(Intent.ACTION_VIEW);
                intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent1.putExtra("route", "/");
                startActivity(intent1);
            }
        });
    }
}
