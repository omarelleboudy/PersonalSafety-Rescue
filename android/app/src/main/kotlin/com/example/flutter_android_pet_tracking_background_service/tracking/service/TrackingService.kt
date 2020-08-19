package com.example.flutter_android_pet_tracking_background_service.tracking.service

interface TrackingService {
    fun start()
    fun stop()
    fun isTracking(): Boolean
    fun attachListener(listener: PetTrackingListener?)
}