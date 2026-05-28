/// Feature flags do app.
///
/// Use estas constantes para esconder funcionalidades que ainda não
/// estão prontas para produção (ex.: features que dependem de
/// In-App Purchase e podem causar rejeição na App Store).
///
/// Para reativar uma feature, troque o valor para `true` e faça
/// rebuild — todos os pontos de entrada da UI consultam este flag.
library;

/// 💰 Monetização (gifts, wallet, loja, live commerce).
///
/// Apple Guideline 3.1.1: bens digitais consumidos no app devem
/// usar In-App Purchase. IAP implementado em v1.0.5+ (Android + iOS),
/// portanto monetização ativa.
const bool kEnableMonetization = true;
