import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers.dart';
import '../../core/database/value_types.dart';
import 'progress_repository.dart';

final progressProvider = StreamProvider.autoDispose
    .family<ProgressSnapshot, ({CalendarDate week, String zone})>(
      (ref, range) =>
          repositoryStream(ref, (r) => r.watchProgress(range.week, range.zone)),
      retry: (count, error) => null,
    );
