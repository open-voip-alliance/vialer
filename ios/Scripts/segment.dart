import 'util.dart';

Future<void> main(List<String> arguments) async {
  final dartDefines = parseDartDefinesFromArguments(arguments);

  await writeXconfigFile(
    name: 'Segment',
    values: {
      'SEGMENT_KEY': dartDefines['SEGMENT_IOS_KEY'] ?? '',
    },
  );
}
