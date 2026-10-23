// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_dont_list/main.dart';
import 'package:to_dont_list/objects/item.dart';
import 'package:to_dont_list/widgets/to_do_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "dart:convert";

void main() {
  setUp(() =>
      SharedPreferences.setMockInitialValues({})); // first line inside main()
  // Yes, you really need the MaterialApp and Scaffold
  testWidgets('Saved items are loaded when the app starts', (tester) async {
    SharedPreferences.setMockInitialValues({
      'groceries': jsonEncode([
        {'name': 'eggs', 'quantity': 12, 'done': false}
      ]),
    });
    await tester.pumpWidget(const MaterialApp(home: ToDoList()));
    await tester.pumpAndSettle();

    expect(find.text('eggs'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
  testWidgets('ToDoListItem has a text', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: GroceryListItem(
                item: GroceryItem(name: "test", quantity: 1),
                completed: true,
                onListChanged: (GroceryItem item, bool completed) {},
                onDeleteItem: (GroceryItem item) {}))));
    final textFinder = find.text('test');

    // Use the `findsOneWidget` matcher provided by flutter_test to verify
    // that the Text widgets appear exactly once in the widget tree.
    expect(textFinder, findsOneWidget);
  });

  testWidgets('ToDoListItem has a Circle Avatar with item count',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: GroceryListItem(
                item: GroceryItem(name: "test", quantity: 1),
                completed: true,
                onListChanged: (GroceryItem item, bool completed) {},
                onDeleteItem: (GroceryItem item) {}))));
    final quantityFinder = find.text("1");
    final avatarFinder = find.byType(CircleAvatar);

    CircleAvatar circ = tester.firstWidget(avatarFinder);
    Text ctext = circ.child as Text;

    // Use the `findsOneWidget` matcher provided by flutter_test to verify
    // that the Text widgets appear exactly once in the widget tree.
    expect(quantityFinder, findsOneWidget);
    expect(circ.backgroundColor, Colors.black54);
    expect(ctext.data, "1");
  });

  testWidgets('Default ToDoList has one item', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ToDoList()));

    final listItemFinder = find.byType(GroceryListItem);

    expect(listItemFinder, findsOneWidget);
  });

  testWidgets('Clicking and Typing adds item to ToDoList', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ToDoList()));

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // Pump after every action to rebuild the widgets
    expect(find.text("hi"), findsNothing);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pump();
    expect(find.text("hi"), findsOneWidget);

    await tester.tap(find.byKey(const Key("OKButton")));
    await tester.pump();
    expect(find.text("hi"), findsOneWidget);

    final listItemFinder = find.byType(GroceryListItem);

    expect(listItemFinder, findsNWidgets(2));
  });

  testWidgets(
      'Increment and Decrement buttons add to and subtract from quantity',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ToDoList()));

    await tester.tap(find.byKey(const Key("Increment")));
    await tester.pump();
    expect(find.text("2"), findsOneWidget);

    await tester.tap(find.byKey(const Key("Decrement")));
    await tester.pump();
    expect(find.text("1"), findsOneWidget);
  });
  // One to test the tap and press actions on the items?
}
