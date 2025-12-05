enum ChartType {
  weekly,
  monthly,
  dateRange;

  String getBadgeKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weeklyChartBadge';
      case ChartType.monthly:
        return 'monthlyChartBadge';
      case ChartType.dateRange:
        return 'dateRangeChartBadge';
    }
  }

  String getSemanticLabelKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weeklyExpensesChart';
      case ChartType.monthly:
        return 'monthlyExpensesChart';
      case ChartType.dateRange:
        return 'dateRangeExpensesChart';
    }
  }
}
