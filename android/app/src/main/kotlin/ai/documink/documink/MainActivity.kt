package ai.documink.documink

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.os.StatFs
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Phase 4c: a tiny first-party channel so Dart can toggle FLAG_SECURE on the
    // window (block screenshots / recents preview) while a sensitive screen —
    // e.g. the decrypted original-document viewer — is showing.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "documink/screen_security",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    val secure = call.arguments as? Boolean ?: false
                    runOnUiThread {
                        if (secure) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Phase 11: device-capability signals for the Tier-4 profiler. Read-only
        // system facts (RAM / free storage / CPU cores / OS version) — no PII and
        // no permissions required. Mirrors AndroidDeviceSignalCollector (Dart).
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "documink/device_signals",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "collect" -> {
                    val am =
                        getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val memInfo = ActivityManager.MemoryInfo()
                    am.getMemoryInfo(memInfo)
                    val stat = StatFs(filesDir.absolutePath)
                    val freeBytes = stat.availableBlocksLong * stat.blockSizeLong
                    result.success(
                        mapOf(
                            "ramBytes" to memInfo.totalMem,
                            "freeStorageBytes" to freeBytes,
                            "cpuCores" to Runtime.getRuntime().availableProcessors(),
                            "platformVersion" to Build.VERSION.SDK_INT,
                        ),
                    )
                }
                else -> result.notImplemented()
            }
        }
    }
}
