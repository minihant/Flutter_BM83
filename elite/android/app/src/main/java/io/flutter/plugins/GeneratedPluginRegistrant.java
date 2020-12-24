package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import top.kikt.bt.ble.bluetooth_ble.BluetoothBlePlugin;
import com.gonoter.flutter_beep.FlutterBeepPlugin;
import dev.flutter.plugins.integration_test.IntegrationTestPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    BluetoothBlePlugin.registerWith(registry.registrarFor("top.kikt.bt.ble.bluetooth_ble.BluetoothBlePlugin"));
    FlutterBeepPlugin.registerWith(registry.registrarFor("com.gonoter.flutter_beep.FlutterBeepPlugin"));
    IntegrationTestPlugin.registerWith(registry.registrarFor("dev.flutter.plugins.integration_test.IntegrationTestPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
