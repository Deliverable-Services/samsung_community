package com.samsung.samsung_community

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val display = context.display
            display?.let {
                val modes = it.supportedModes
                val maxMode = modes.maxByOrNull { mode -> mode.refreshRate }
                maxMode?.let { mode ->
                    val layoutParams = window.attributes
                    layoutParams.preferredDisplayModeId = mode.modeId
                    window.attributes = layoutParams
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = window.windowManager.defaultDisplay
            val modes = display.supportedModes
            val maxMode = modes.maxByOrNull { mode -> mode.refreshRate }
            maxMode?.let { mode ->
                val layoutParams = window.attributes
                layoutParams.preferredDisplayModeId = mode.modeId
                window.attributes = layoutParams
            }
        }
    }
}
