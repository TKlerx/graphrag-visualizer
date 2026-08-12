# Public Corpus Download URLs

Use `demo/scripts/prepare-forterro-corpus.ps1` to download these automatically where possible. If a source blocks scripted download, download it manually and save it under `demo/corpus/raw/` with the listed local filename.

| Source | Local filename | URL |
| --- | --- | --- |
| Partners Group Forterro investment case study | `partners-group-forterro-case-study.html` | https://www.partnersgroup.com/en/our-investments/private-equity/forterro |
| Partners Group Forterro acquisition announcement | `partners-group-forterro-acquisition.html` | https://www.partnersgroup.com/news-and-views/press-releases/investment-news/detail?news_id=c6a69c36-9083-406e-8ef0-0349317325fb |
| Forterro investor page | `forterro-investors.html` | https://www.forterro.com/en/investors |
| Battery Ventures Forterro case study | `battery-forterro-case-study.html` | https://www.battery.com/blog/forterro-case-study/ |
| European Commission merger case M.10709 | `eu-merger-m10709.pdf` | https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=CELEX%3A32022M10709 |
| Partners Group Private Markets Outlook 2026 | `partners-group-private-markets-outlook-2026.html` | https://www.partnersgroup.com/en/news-and-views/perspective/private-markets-outlook-2026 |
| Partners Group Annual Report 2024 | `partners-group-annual-report-2024.pdf` | https://www.partnersgroup.com/~/media/Files/P/Partnersgroup/Universal/shareholders/reports-and-presentations/2025/annual-report-2024.pdf |
| Bain Global Private Equity Report 2026 | `bain-global-private-equity-report-2026.pdf` | https://www.bain.com/globalassets/noindex/2026/bain-report_global-private-equity-report-2026.pdf |
| McKinsey Global Private Markets Report 2026 | `global-private-markets-report-2026-full-report.pdf` | https://www.mckinsey.com/industries/private-capital/our-insights/global-private-markets-report |
| PitchBook 2026 US Private Equity Outlook | `pitchbook-us-private-equity-outlook-2026.pdf` | https://pitchbook.brightspotcdn.com/a2/46/d213c56546e8809e36c4cb4a700f/2026-us-private-equity-outlook.pdf |
| Proalpha company overview | `proalpha-about.html` | https://www.proalpha.com/en/about-us |
| Proalpha success story and ownership milestones | `proalpha-success-story.html` | https://www.proalpha.com/en/about-us/success-story |
| Arma Partners proALPHA majority recapitalisation by ICG | `arma-proalpha-icg-transaction.html` | https://www.armapartners.com/advised-bregal-unternehmerkapital-on-the-sale-of-its-portfolio-company-proalpha-business-solutions-gmbh-a-leading-provider-of-enterprise-resource-planning-software-to-icg/ |
| Proalpha acquisition of Persis | `proalpha-persis-acquisition.html` | https://www.proalpha.com/en/blog/akquisition_persis |
| Proalpha acquisition of GEDYS IntraWare | `proalpha-gedys-acquisition.html` | https://www.proalpha.com/en/blog/proalpha-acquires-gedys |
| Proalpha acquisition of MKG | `proalpha-mkg-acquisition.html` | https://www.proalpha.com/en/blog/acquisition-mkg-erp |
| Proalpha ERP release 9.5 | `proalpha-erp-release-95.html` | https://www.proalpha.com/en/blog/erp-release-9.5 |

## Manual Download Notes

- The McKinsey source failed during the first scripted run in this environment. If it fails again, download the page manually from a browser or replace it with another public private-markets report.
- PDFs should be converted to Markdown before GraphRAG indexing with `demo/scripts/convert-corpus-pdfs-to-markdown.ps1`.
