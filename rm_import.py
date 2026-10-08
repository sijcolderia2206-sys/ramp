with open('lib/core/state/ramp_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import '../services/firestore_service.dart';", "")

with open('lib/core/state/ramp_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
