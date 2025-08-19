enum ChartType {
  weekly,
  monthly;
  
  String getBadgeKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weekly_chart_badge';
      case ChartType.monthly:
        return 'monthly_chart_badge';
    }
  }
  
  String getSemanticLabelKey() {
    switch (this) {
      case ChartType.weekly:
        return 'weekly_expenses_chart';
      case ChartType.monthly:
        return 'monthly_expenses_chart';
    }
  }
}