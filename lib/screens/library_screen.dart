import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Feature 1: Private Knowledge Library.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  DocType? _type;
  String _query = '';

  DocType _guessType(String? extension) => switch (extension?.toLowerCase()) {
        'ppt' || 'pptx' || 'key' => DocType.slides,
        'txt' || 'md' || 'doc' || 'docx' => DocType.notes,
        _ => DocType.book,
      };

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'md'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    learner.markMilestone('uploaded');
    learner.addDocs([
      for (final f in result.files)
        LibraryDoc(
          id: 'upload-$stamp-${f.name}',
          title: f.name,
          type: _guessType(f.extension),
          course: 'Unsorted',
          pages: 0,
          added: 'Just now',
          indexed: false,
        ),
    ]);
    showToast(
      context,
      'Added ${result.files.length} file${result.files.length == 1 ? '' : 's'}. '
      'They become searchable once the AI backend indexes them.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final p = context.palette;
        final all = learner.docs;
        final q = _query.toLowerCase();
        final visible = all
            .where((d) => _type == null || d.type == _type)
            .where((d) => q.isEmpty || d.title.toLowerCase().contains(q) || d.course.toLowerCase().contains(q))
            .toList();
        final pages = all.fold(0, (sum, d) => sum + d.pages);

        return PageScaffold(
          builder: (context, width) => [
            FadeSlideIn(
              child: PageHeader(
                title: 'My Library',
                subtitle: '${all.length} documents · $pages pages · all your learning material in one place',
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: width < 600 ? double.infinity : 360,
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: fieldDecoration(
                      context,
                      hint: 'Filter by title or course',
                      prefixIcon: Icon(Icons.search, size: 20, color: p.subtle),
                      fill: p.card,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _upload,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload files'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('All (${all.length})'),
                  selected: _type == null,
                  onSelected: (_) => setState(() => _type = null),
                ),
                for (final t in DocType.values)
                  ChoiceChip(
                    avatar: Icon(t.icon, size: 16, color: t.color),
                    label: Text('${t.label} (${all.where((d) => d.type == t).length})'),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (visible.isEmpty)
              Panel(
                child: Text(
                  'No documents match. Clear the filter or upload more material.',
                  style: TextStyle(color: p.mutedForeground),
                ),
              )
            else
              ResponsiveGrid(
                minItemWidth: 260,
                children: [for (final d in visible) _DocCard(doc: d)],
              ),
          ],
        );
      },
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc});

  final LibraryDoc doc;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sections = passages.where((x) => x.docId == doc.id).length;
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DocTypeBadge(doc.type),
              const Spacer(),
              doc.indexed
                  ? NeutralPill(doc.type.label)
                  : Pill(label: 'Waiting to be indexed', color: AppColors.brand),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            doc.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 4),
          Text(doc.course, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
          const SizedBox(height: 12),
          Text(
            doc.indexed
                ? '${doc.pages} pages · $sections indexed sections · ${doc.added}'
                : 'Added ${doc.added.toLowerCase()}',
            style: AppTheme.mono(11, color: p.subtle),
          ),
        ],
      ),
    );
  }
}
