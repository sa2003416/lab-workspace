class Book {
  String name;
  String author;
  int yearOfPublication;

  // Book(String name, String author, int yearOfPublication) {
  //   this.name = name;
  //   this.author = author;
  //   this.yearOfPublication = yearOfPublication;
  // }
  Book({
    required this.name,
    required this.author,
    required this.yearOfPublication,
  });

  // have  a way to change this object into json

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "author": author,
      "yearOfPublication": yearOfPublication,
    };
  }

  factory Book.fromJSON(Map<String, dynamic> json) {
    return Book(
      name: json["name"],
      author: json["author"],
      yearOfPublication: json["yearOfPublication"],
    );
  }

  @override
  String toString() {
    return """"
          Title : $name
          author : $author
          yearOfPublication : $yearOfPublication
        """;
  }
}
