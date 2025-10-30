enum ChartType {
  weekly,
  monthly;

  String getBadgeKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weeklyChartBadge';
      case ChartType.monthly:
        return 'monthlyChartBadge';
    }
  }

  String getSemanticLabelKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weeklyExpensesChart';
      case ChartType.monthly:
        return 'monthlyExpensesChart';
    }
  }
}
