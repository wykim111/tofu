class Dog {
  final String id;
  final String name;
  final String breed;
  final String? imageUrl;
  final String ownerId;

  Dog({
    required this.id,
    required this.name,
    required this.breed,
    this.imageUrl,
    required this.ownerId,
  });
}
