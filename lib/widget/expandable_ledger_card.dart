import 'package:flutter/material.dart';

class ExpandableLedgerCard extends StatefulWidget {
  final Map<String, dynamic> row;
  final String? title;
  final List<CardField> primaryFields;
  final List<CardField> detailFields;
  final bool showAllDetailFields;
  final Color? accentColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final String Function(dynamic val)? numberFormat;

  const ExpandableLedgerCard({
    super.key,
    required this.row,
    this.title,
    required this.primaryFields,
    required this.detailFields,
    this.showAllDetailFields = true,
    this.accentColor,
    this.icon,
    this.onTap,
    this.numberFormat,
  });

  @override
  State<ExpandableLedgerCard> createState() => _ExpandableLedgerCardState();
}

class _ExpandableLedgerCardState extends State<ExpandableLedgerCard> {
  bool _expanded = false;

  String _fmt(dynamic val) {
    if (widget.numberFormat != null) return widget.numberFormat!(val);
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }

  String _dateShort(String d) => d.length >= 10 ? d.substring(0, 10) : d;

  String _val(String key) {
    final r = widget.row;
    if (r.containsKey(key)) return (r[key] ?? '').toString();
    for (final k in r.keys) {
      if (k.toString().toLowerCase() == key.toLowerCase()) {
        return (r[k] ?? '').toString();
      }
    }
    return '';
  }

  Color _lighter(Color c, [double amount = 0.3]) {
    final hsl = HSLColor.fromColor(c);
    final lighter = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighter.toColor();
  }

  Color _darker(Color c, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(c);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Colors.indigo;
    final cardIcon = widget.icon ?? Icons.receipt_long;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _expanded
              ? [_darker(accent, 0.1), _darker(accent, 0.3)]
              : [_lighter(accent, 0.1), _darker(accent, 0.15)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: _expanded ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              } else {
                setState(() => _expanded = !_expanded);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cardIcon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNameContent(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  _buildAmountsRow(),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedDetails(),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildNameContent() {
    final cols = widget.primaryFields;
    final nameField = cols.firstWhere(
      (f) => f.isBold,
      orElse: () => cols.first,
    );
    final nameValue = _val(nameField.key);
    final subtitleFields = cols.where((f) => !f.isBold && !f.isAmount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameValue.isNotEmpty ? nameValue : (widget.row['AcName']?.toString() ?? 'Record'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitleFields.isNotEmpty)
          Text(
            _val(subtitleFields.first.key),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildAmountsRow() {
    final cols = widget.primaryFields;
    if (cols.length <= 2) return const SizedBox.shrink();

    final valueFields = cols.sublist(2);
    if (valueFields.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: valueFields.map((field) {
          final raw = widget.row[field.key];
          final display = field.isAmount ? _fmt(raw ?? 0) : (raw?.toString() ?? '');
          final isDate = field.key.toLowerCase().contains('date') && !field.isAmount;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isDate ? _dateShort(display) : display,
                      style: TextStyle(
                        color: field.color ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    List<CardField> fields = List.from(widget.detailFields);

    if (widget.showAllDetailFields) {
      final primaryKeys = widget.primaryFields.map((f) => f.key.toLowerCase()).toSet();
      final detailKeys = fields.map((f) => f.key.toLowerCase()).toSet();
      final skipKeys = {
        ...primaryKeys, ...detailKeys,
        '_statuscolor', '_typelabel', '_selected',
      };

      for (final key in widget.row.keys) {
        final lk = key.toString().toLowerCase();
        if (skipKeys.contains(lk)) continue;
        final val = widget.row[key];
        if (val == null || val.toString().isEmpty) continue;
        final isAmt = val is num || (val is String && double.tryParse(val) != null);
        fields.add(CardField(
          key: key.toString(),
          label: key.toString(),
          isAmount: isAmt,
        ));
      }
    }

    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 10),
          ...List.generate(fields.length, (index) {
            final field = fields[index];
            final raw = _val(field.key);
            final display = field.isAmount ? _fmt(widget.row[field.key] ?? 0) : raw;
            final isDate = field.key.toLowerCase().contains('date') && !field.isAmount;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      field.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDate ? _dateShort(display) : display,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: field.isBold ? FontWeight.w700 : FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CardField {
  final String key;
  final String label;
  final bool isAmount;
  final bool isBold;
  final int flex;
  final Color? color;

  const CardField({
    required this.key,
    required this.label,
    this.isAmount = false,
    this.isBold = false,
    this.flex = 1,
    this.color,
  });
}

class PaginatedCardList extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Widget Function(Map<String, dynamic> row, int index) cardBuilder;
  final ScrollController? scrollController;
  final String? emptyMessage;
  final Future<List<Map<String, dynamic>>> Function(int page, int pageSize)? fetchPage;
  final int pageSize;
  final int fetchSize;
  final bool showCountFooter;

  const PaginatedCardList({
    super.key,
    required this.data,
    required this.cardBuilder,
    this.scrollController,
    this.emptyMessage,
    this.fetchPage,
    this.pageSize = 20,
    this.fetchSize = 40,
    this.showCountFooter = true,
  });

  @override
  State<PaginatedCardList> createState() => _PaginatedCardListState();
}

class _PaginatedCardListState extends State<PaginatedCardList> {
  late ScrollController _scrollController;
  bool _fetching = false;
  bool _hasMore = true;
  int _currentPage = 0;
  List<Map<String, dynamic>> _displayed = [];
  List<Map<String, dynamic>> _buffer = [];

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _displayed = List.from(widget.data);
    if (_displayed.isNotEmpty) {
      _currentPage = (_displayed.length / widget.fetchSize).ceil();
    }
    _hasMore = true;
    _scrollController.addListener(_onScroll);
    _prefetch();
  }

  @override
  void didUpdateWidget(covariant PaginatedCardList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _displayed = List.from(widget.data);
      _buffer.clear();
      _currentPage = _displayed.isEmpty ? 0 : (_displayed.length / widget.fetchSize).ceil();
      _hasMore = true;
      _prefetch();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _showMore();
    }
  }

  Future<void> _prefetch() async {
    if (_fetching || !_hasMore || widget.fetchPage == null) return;
    _fetching = true;
    try {
      final newItems = await widget.fetchPage!(_currentPage, widget.fetchSize);
      if (!mounted) return;
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _buffer.addAll(newItems);
        _currentPage++;
        if (newItems.length < widget.fetchSize) _hasMore = false;
      }
    } catch (_) {
    } finally {
      _fetching = false;
    }
  }

  void _showMore() {
    if (_buffer.isEmpty || _fetching) return;
    final take = _buffer.length >= widget.pageSize
        ? widget.pageSize
        : _buffer.length;
    final items = _buffer.sublist(0, take);
    _buffer.removeRange(0, take);
    setState(() {
      _displayed.addAll(items);
    });
    _prefetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayed.isEmpty && !_fetching) {
      return Center(
        child: Text(
          widget.emptyMessage ?? 'No data',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            itemCount: _displayed.length,
            itemBuilder: (ctx, i) {
              return widget.cardBuilder(_displayed[i], i);
            },
          ),
        ),
        if (widget.showCountFooter)
          _buildLoadMoreFooter(_displayed.length),
      ],
    );
  }

  Widget _buildLoadMoreFooter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      color: Colors.grey.shade100,
      child: Center(
        child: Text(
          _fetching
              ? 'Loading more...'
              : _hasMore
                  ? 'Loaded $total records (scroll for more)'
                  : 'Loaded $total records',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
