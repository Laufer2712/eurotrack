class CarritoItem {
  final int productoId;
  final String nombre;
  final double precio;
  final String? imagenUrl;
  final String marca;
  final int stock;
  int cantidad;

  CarritoItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
    required this.marca,
    required this.stock,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toJson() => {
    'productoId': productoId,
    'nombre': nombre,
    'precio': precio,
    'imagenUrl': imagenUrl,
    'marca': marca,
    'stock': stock,
    'cantidad': cantidad,
  };

  factory CarritoItem.fromJson(Map<String, dynamic> json) => CarritoItem(
    productoId: json['productoId'],
    nombre: json['nombre'],
    precio: json['precio'],
    imagenUrl: json['imagenUrl'],
    marca: json['marca'],
    stock: json['stock'],
    cantidad: json['cantidad'],
  );
}