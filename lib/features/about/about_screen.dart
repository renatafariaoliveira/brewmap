import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/components/brew_card.dart';
import 'package:brewmap/core/components/section_title.dart';
import 'package:brewmap/features/about/components/about_footer.dart';
import 'package:brewmap/features/about/components/about_header.dart';
import 'package:brewmap/features/about/components/about_rich_text.dart';
import 'package:brewmap/features/about/components/hero_section.dart';
import 'package:brewmap/features/about/components/project_info_card.dart';
import 'package:flutter/material.dart';

// constants
const _kAuthorName = 'Renata Oliveira';
const _kInstructorName = 'Filipe Barroso';
const _kPresentationDate = 'Maio de 2026';
const _kGitHubUrl = 'https://github.com/renatafariaoliveira/brewmap';
const _kMaxContentWidth = 720.0;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          const AboutHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kMaxContentWidth,
                  ),
                  child: Column(
                    children: [
                      const AboutHeroSection(),
                      const SizedBox(height: 32),
                      _AboutContentCard(
                        title: 'O QUE É',
                        child: const AboutRichText(children: [
                          TextSpan(text: 'O '),
                          TextSpan(
                            text: 'BrewMap',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ' é uma aplicação web desenvolvida em ',
                          ),
                          TextSpan(
                            text: 'Flutter',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                ' para explorar e descobrir cervejarias artesanais ao redor do mundo. Com um mapa interativo e filtros por tipo, você encontra o lugar certo para o próximo copo.',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      _AboutContentCard(
                        title: 'COMO FUNCIONA',
                        child: const AboutRichText(children: [
                          TextSpan(
                            text: 'Os dados são consumidos em tempo real da ',
                          ),
                          TextSpan(
                            text: 'Open Brewery DB',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                ', uma API pública e gratuita com informações de mais de 8.000 cervejarias. Nenhum cadastro ou chave de acesso é necessário — basta buscar e explorar.',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      const ProjectInfoCard(
                        authorName: _kAuthorName,
                        instructorName: _kInstructorName,
                        presentationDate: _kPresentationDate,
                        githubUrl: _kGitHubUrl,
                      ),
                      const SizedBox(height: 40),
                      const AboutFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutContentCard extends StatelessWidget {
  const _AboutContentCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BrewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrewSectionTitle(title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
