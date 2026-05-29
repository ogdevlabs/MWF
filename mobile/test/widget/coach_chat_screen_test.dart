import 'package:flutter_test/flutter_test.dart';

// Wave 0 stub — tests will be filled when CoachChatScreen is implemented
void main() {
  group('CoachChatScreen', () {
    testWidgets('renders chat bubbles from feedback stream', (tester) async {
      // TODO: implement — pump CoachChatScreen with mock stream
    });

    testWidgets('pending message shows clock icon', (tester) async {
      // TODO: implement — verify Icons.schedule visible for pending status
    });

    testWidgets('compose bar enables send when text is not empty', (tester) async {
      // TODO: implement — verify send button state
    });

    testWidgets('compose bar disables send when text is empty and no photo', (tester) async {
      // TODO: implement — verify send button disabled
    });
  });
}
