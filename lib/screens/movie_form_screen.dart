import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Importação necessária
import '../models/movie.dart';
import '../services/database_helper.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie; // Objeto Movie opcional

  MovieFormScreen({this.movie});

  @override
  _MovieFormScreenState createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  String _ageRating = 'Livre';
  double _rating = 0; // Valor padrão da nota

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      // Preenche os campos com os dados existentes do filme
      _titleController.text = widget.movie!.title;
      _imageUrlController.text = widget.movie!.imageUrl;
      _genreController.text = widget.movie!.genre;
      _durationController.text = widget.movie!.duration;
      _descriptionController.text = widget.movie!.description;
      _yearController.text = widget.movie!.year.toString();
      _ageRating = widget.movie!.ageRating;
      _rating = widget.movie!.rating;
    }
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movie?.id, // Retém o ID se for uma atualização
        title: _titleController.text,
        imageUrl: _imageUrlController.text,
        genre: _genreController.text,
        duration: _durationController.text,
        year: int.parse(_yearController.text),
        description: _descriptionController.text,
        rating: _rating,
        ageRating: _ageRating,
      );

      if (widget.movie == null) {
        // Inserir novo filme
        await DatabaseHelper.instance.insertMovie(movie);
      } else {
        // Atualizar filme existente
        await DatabaseHelper.instance.updateMovie(movie);
      }

      Navigator.pop(context, true); // Retorna sucesso
    }
  }

  @override
  void dispose() {
    // Limpa os controladores ao descartar o widget
    _titleController.dispose();
    _imageUrlController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Cadastrar Filme' : 'Editar Filme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL da Imagem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da imagem';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(labelText: 'Gênero'),
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duração'),
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição do filme';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _ageRating,
                items: ['Livre', '10 anos', '12 anos', '14 anos', '16 anos', '18 anos']
                    .map((rating) => DropdownMenuItem(
                          value: rating,
                          child: Text(rating),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _ageRating = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Faixa Etária'),
              ),
              SizedBox(height: 16),
              Text('Nota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMovie,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
