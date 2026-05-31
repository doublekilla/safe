class Formatters {
  static String formatDate(String? dateStr, {bool includeYear = false}) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      if (includeYear) {
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      } else {
        return '${date.day} ${months[date.month - 1]}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    // Usually time comes as HH:mm:ss
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return timeStr;
  }

  static String formatPrice(double cost) {
    if (cost <= 0) return 'Free';
    final str = cost.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return 'Rp $str';
  }

  static String capitalizeWords(String input) {
    if (input.isEmpty) return '';
    return input.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
  }
}
