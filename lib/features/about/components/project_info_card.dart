import 'package:brewmap/core/components/brew_card.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/core/utils/url_launcher_helper.dart';
import 'package:flutter/material.dart';

class ProjectInfoCard extends StatelessWidget {
  const ProjectInfoCard({
    super.key,
    required this.authorName,
    required this.instructorName,
    required this.presentationDate,
    required this.githubUrl,
  });

  final String authorName;
  final String instructorName;
  final String presentationDate;
  final String githubUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return BrewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Informações do projeto',
                style: kBodyTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProjectInfoRow(
            icon: Icons.person_outline,
            label: 'Autor',
            value: authorName,
            valueColor: kAccent,
          ),
          _ProjectInfoRow(
            icon: Icons.school_outlined,
            label: 'Formador',
            value: instructorName,
          ),
          _ProjectInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Data',
            value: presentationDate,
          ),
          _ProjectInfoRow(
            icon: Icons.code,
            label: 'Repositório',
            githubUrl: githubUrl,
          ),
        ],
      ),
    );
  }
}

class _ProjectInfoRow extends StatelessWidget {
  const _ProjectInfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.githubUrl,
  }) : assert(value != null || githubUrl != null);

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final String? githubUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: kBodyTextStyle.copyWith(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: githubUrl != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: _GitHubLink(url: githubUrl!),
                  )
                : Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: kBodyTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? colors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GitHubLink extends StatelessWidget {
  const _GitHubLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final displayUrl = displayWebsiteUrl(url);

    return Material(
      color: const Color(0xFF1A3050),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => launchExternalUrl(context, url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link_rounded,
                size: 16,
                color: Color(0xFF6BA3E8),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  displayUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: kBodyTextStyle.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF6BA3E8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

