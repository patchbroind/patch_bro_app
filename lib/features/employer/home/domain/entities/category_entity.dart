class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.iconUrl,
    this.isActive = true,
    this.displayOrder = 0,
    this.activeWorkersCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? iconUrl;
  final bool isActive;
  final int displayOrder;
  final int activeWorkersCount;
}