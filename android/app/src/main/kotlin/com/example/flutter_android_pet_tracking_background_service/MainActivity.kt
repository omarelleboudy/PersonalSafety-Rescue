package com.example.flutter_android_pet_tracking_background_service

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import com.example.flutter_android_pet_tracking_background_service.tracking.model.PathLocation
import com.example.flutter_android_pet_tracking_background_service.tracking.model.toJson
import com.example.flutter_android_pet_tracking_background_service.tracking.service.PetTrackingListener
import com.example.flutter_android_pet_tracking_background_service.tracking.service.PetTrackingService
import com.example.flutter_android_pet_tracking_background_service.tracking.service.TrackingService
import com.example.flutter_android_pet_tracking_background_service.utils.DartCall
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

private const val METHOD_CHANNEL = "RescueChannel"

class MainActivity : FlutterActivity(), PetTrackingListener {
    private var trackingService: TrackingService? = null
    private lateinit var connection: ServiceConnection
    private var serviceBound = false
    private var serviceBoundResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        setUpMethodChannelListener()
    }

    public fun SendLocationToServer(latitude: String, longitude: String)
    {


    }

    override fun onStart() {
        super.onStart()
        bindService(object : PetTrackingServiceHandler {
            override fun onBound() {
                Log.e("SRI", "Bound Service")
                trackingService?.attachListener(this@MainActivity)
                serviceBound = true
                serviceBoundResult?.let {
                    it.success(true)
                    serviceBoundResult = null
                }
            }
        })
    }

    override fun onStop() {
        super.onStop()
        trackingService?.let {
            it.attachListener(null)
            unbindService(connection)
            serviceBound = false
        }
    }

    override fun onNewLocation(location: PathLocation) {
        location.toJson()?.let {
            invokePathLocation(it)
        }
    }

    private fun bindService(serviceHandler: PetTrackingServiceHandler) {
        connection = object : ServiceConnection {
            override fun onServiceDisconnected(name: ComponentName?) {
                trackingService = null
            }

            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                val binder = service as PetTrackingService.LocalBinder
                trackingService = binder.getService()
                serviceHandler.onBound()
            }
        }
        val intent = Intent(this, PetTrackingService::class.java)
        bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }


    private fun startPetTrackingService() {
        if ((checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION),
                    143)
            return
        } else {
            startService(Intent(this, PetTrackingService::class.java))
            trackingService?.start()
        }
    }

    private fun stopPetTrackingService() {
        trackingService?.stop()
    }

    private fun isTrackingPet(): Boolean {
        val service = trackingService
        return service?.isTracking() ?: false
    }

    private fun setUpMethodChannelListener() {
        MethodChannel(flutterView, METHOD_CHANNEL).setMethodCallHandler { methodCall, result ->
            when {
                methodCall.method == DartCall.START_PET_TRACKING -> {
                    startPetTrackingService()
                    result.success("Tracking rescuer location")
                }
                methodCall.method == DartCall.STOP_PET_TRACKING -> {
                    stopPetTrackingService()
                    result.success("Rescuer location tracking stopped")
                }
                methodCall.method == DartCall.IS_PET_TRACKING_ENABLED -> result.success(isTrackingPet())
                methodCall.method == DartCall.SERVICE_BOUND -> {
                    if (trackingService != null) {
                        result.success(serviceBound)
                        return@setMethodCallHandler
                    }
                    serviceBoundResult = result
                }
            }
        }
    }

    private fun invokePathLocation(pathLocation: String) {
        MethodChannel(flutterView, METHOD_CHANNEL).invokeMethod(DartCall.PATH_LOCATION, pathLocation)
    }


    interface PetTrackingServiceHandler {
        fun onBound()
    }
}
