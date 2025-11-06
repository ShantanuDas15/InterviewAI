// lib/services/vapi_js_interop.dart
@JS()
library vapi;

import 'dart:js_interop';

/// JavaScript interop for Vapi Web SDK
/// Requires the Vapi script to be loaded in web/index.html
@JS('Vapi')
@staticInterop
class VapiJS {
  external factory VapiJS(VapiOptions options);
}

extension VapiJSExtension on VapiJS {
  external void start(VapiStartOptionsJS options);
  external void stop();
  external void on(String event, JSFunction callback);
}

@JS()
@anonymous
@staticInterop
class VapiOptions {
  external factory VapiOptions({required String publicKey});
}

@JS()
@anonymous
@staticInterop
class VapiStartOptionsJS {
  external factory VapiStartOptionsJS({
    required String assistantId,
    VapiAssistantOptionsJS? assistant,
  });
}

@JS()
@anonymous
@staticInterop
class VapiAssistantOptionsJS {
  external factory VapiAssistantOptionsJS({
    String? firstMessage,
    JSObject? variables,
  });
}

/// Helper class to create start options with proper structure
class VapiStartOptions {
  static VapiStartOptionsJS create({
    required String assistantId,
    String? firstMessage,
    Map<String, dynamic>? variables,
  }) {
    VapiAssistantOptionsJS? assistant;

    if (firstMessage != null || variables != null) {
      assistant = VapiAssistantOptionsJS(
        firstMessage: firstMessage,
        variables: variables != null ? _mapToJSObject(variables) : null,
      );
    }

    return VapiStartOptionsJS(assistantId: assistantId, assistant: assistant);
  }

  /// Convert a Dart Map to a JavaScript object
  static JSObject _mapToJSObject(Map<String, dynamic> map) {
    final jsMap = <String, dynamic>{};
    map.forEach((key, value) {
      jsMap[key] = value;
    });
    return jsMap.jsify() as JSObject;
  }
}
