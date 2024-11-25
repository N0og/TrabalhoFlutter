import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/database_helper.dart';
import 'movie_form_screen.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> movies;

  @override
  void initState() {
    super.initState();
    movies = DatabaseHelper.instance.fetchMovies();
  }

  void _refreshMovies() {
    setState(() {
      movies = DatabaseHelper.instance.fetchMovies();
    });
  }

  void _showOptions(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Exibir Dados'),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Alterar'),
                onTap: () async {
                  Navigator.pop(context); // Fecha o menu
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieFormScreen(movie: movie),
                    ),
                  );
                  if (result == true) _refreshMovies();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmes'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Equipe:'),
                    content: Text(
                        'Vitor Weslley Araujo De Medeiros\nGabriel da Silva Nogueira'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar filmes.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum filme cadastrado.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return Dismissible(
                  key: Key(movie.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await DatabaseHelper.instance.deleteMovie(movie.id!);
                    setState(() {
                      snapshot.data!.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${movie.title} foi deletado')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        leading: SizedBox(
                          width: 100,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        title: Text(
                          movie.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.genre),
                            SizedBox(height: 4),
                            Text(movie.duration),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  movie.rating.toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          _showOptions(context, movie);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MovieFormScreen()),
          );
          if (result == true) _refreshMovies();
        },
        child: Icon(Icons.add),
        tooltip: 'Adicionar Filme',
      ),
    );
  }
}
