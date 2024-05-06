String formatNumberToK(int num) {
  if (num >= 1000 && num < 1000000) {
    return '${(num / 1000).toStringAsFixed(1)} K';
  } else if (num >= 1000000) {
    return '${(num / 1000000).toStringAsFixed(2)} M';
  } else {
    return num.toString();
  }
}

String formatNumber(int num) {
  return num.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );
}
