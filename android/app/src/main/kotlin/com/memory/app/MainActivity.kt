package com.memory.app

import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import java.util.Locale

class MainActivity : FlutterActivity() {
    override fun attachBaseContext(newBase: Context?) {
        val context = newBase?.let { updateLocale(it) } ?: newBase
        super.attachBaseContext(context)
    }

    override fun getResources(): Resources {
        val resources = super.getResources()
        val locale = Locale("ko", "KR")
        Locale.setDefault(locale)
        
        val configuration = Configuration(resources.configuration)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            configuration.setLocale(locale)
            return createConfigurationContext(configuration).resources
        } else {
            @Suppress("DEPRECATION")
            configuration.locale = locale
            @Suppress("DEPRECATION")
            resources.updateConfiguration(configuration, resources.displayMetrics)
        }
        return resources
    }

    private fun updateLocale(context: Context): Context {
        val locale = Locale("ko", "KR")
        Locale.setDefault(locale)
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val configuration = Configuration(context.resources.configuration)
            configuration.setLocale(locale)
            context.createConfigurationContext(configuration)
        } else {
            @Suppress("DEPRECATION")
            val resources = context.resources
            @Suppress("DEPRECATION")
            val configuration = resources.configuration
            @Suppress("DEPRECATION")
            configuration.locale = locale
            @Suppress("DEPRECATION")
            resources.updateConfiguration(configuration, resources.displayMetrics)
            context
        }
    }
}

