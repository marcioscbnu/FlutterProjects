import 'package:flutter/widgets.dart';

// Um único observador global para todo o app.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/*
Mesmo que o formulário/detalhes não retornem true no Navigator.pop, o RouteObserver chama didPopNext() 
quando a lista volta a ficar visível, e nós forçamos _refresh() (novo GET).

Mantivemos o then/await após o pushNamed como reforço.

O RouteObserver é um observador do Navigator que avisa quando as rotas (telas) entram ou saem de foco. Com ele, uma tela pode saber que voltou a ser visível (ex.: depois que você fecha o formulário) e então rodar alguma ação—como refazer o GET.

Como funciona:
1. Você registra um RouteObserver no MaterialApp.navigatorObservers.
2. Sua tela implementa RouteAware e se inscreve no observer.
3. O Flutter chama “ganchos” (callbacks) no ciclo de navegação:
    didPush() – esta rota foi empilhada.
    didPop() – esta rota foi removida.
    didPushNext() – outra rota foi empilhada por cima desta (ela ficou em segundo plano).
    didPopNext() – a rota de cima foi removida; esta voltou a ficar visível (é aqui que recarregamos a lista!).

Por que usar?
1. Para recarregar dados quando a tela volta (ex.: você salvou no formulário e retornou).
2. Para pausar/retomar streams, timers, players, etc., conforme a tela fica visível/oculta.

Diferença de conceito:
  NavigatorObserver é a interface genérica para observar navegação.
  RouteObserver é uma implementação pronta que facilita notificar rotas específicas via o mixin RouteAware.

Armadilhas comuns:

  * Esquecer de registrar em navigatorObservers.
  * Esquecer de inscrever (subscribe) e desinscrever (unsubscribe) a rota.
  * Usar didPop() (é quando esta rota sai), quando o que você quer é didPopNext() (quando ela volta a aparecer).

Em resumo: o RouteObserver é a forma mais confiável de “saber que a tela ficou visível de novo” e, por isso, 
excelente para refazer o GET ao retornar de uma tela de edição.
*/
