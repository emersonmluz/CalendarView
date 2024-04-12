# CalendarView

<img width="427" alt="Captura de Tela 2024-04-10 às 14 32 05" src="https://github.com/emersonmluz/CalendarView/assets/111133275/af73f78a-18b1-4b73-808c-f69092bdb808">

## Como usar

Por trata-se de uma UIView, para adicionar ao seu projeto basta copiar o código e inserir como uma nova classe, então é só criar uma instância, adiciona-la a hierarquia da sua view e configurar as constraints.

Você pode usar o CalendarView para exibir apenas o calendário como também pode selecionar dias para alguma finalidade, por padrão ele vem desabilitado para interação, mas você pode habilitar a seleção de dias acessando a propriedade **enableInteraction** conforme abaixo: 

**calendarView.enableInteraction = true**


### Seleção de dias

Existe dois tipos de seleção, o default é poder selecionar dias variados conforme a imagem abaixo:

<img width="427" alt="Captura de Tela 2024-04-10 às 14 33 00" src="https://github.com/emersonmluz/CalendarView/assets/111133275/78725261-5f47-4cc8-8185-b7a77c6280a6">

Mas também é possível alterar para dias corridos. Para isso basta informar o número de dias no argumento do método **numberOfContinuousDays**, então ao selecionar um dia irá selecionar a quantidade de dias corridos automaticamente.

**calendarView.numberOfContinuousDays(15)**

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 30" src="https://github.com/emersonmluz/CalendarView/assets/111133275/ced1c744-962b-4847-8d50-6a590c6ff2e9">

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 36" src="https://github.com/emersonmluz/CalendarView/assets/111133275/bbd773fb-35a7-4235-af42-63fe3131a8c7">

<img width="427" alt="Captura de Tela 2024-04-10 às 14 35 43" src="https://github.com/emersonmluz/CalendarView/assets/111133275/9ee7dc96-3101-4035-9637-f7cd73ed212c">

Para recuperar os dias selecionados atribua o **delegate** a sua instância:

**calendarView.delegate = self**

Implemente o protocolo **CalendarViewDelegate**:

**extension ViewController: CalendarViewDelegate {**<br>
    **func savedDates(transfer dates: [Date]) { }**<br>
**}**<br>


### Métodos

A seguir veja os métodos disponíveis em CalendarView:

**dateInit(month: Int, year: Int)**<br>Por padrão, o calendário sempre é aberto no mês atual, mas você definir o ano e o mês que será iniciado.

**dayPlus(Int)**<br>Defini que a seleção só é possível apartir da data atual mais o número de dias indicado.

**numberOfContinuousDays(Int)**<br>Defini quantos dias corridos será automaticamente selecionado após clicar em algum dia. Quando não definido ou se o valor for 0 ou menor equivale a seleção livre de dias. Se for definido 1 só será possível selecionar 1 dia, se o valor for maior que um será selecionado automaticamente o número indicado de dias, se optar por essa opção só é possível ter um intervalo de dias por vez, ou seja, se já houver dias selecionado e você clicar em outro dia, será apagado a seleção atual e o último dia será considerado a data inicial para o novo intervalo. 

**enabledCalendar(Bool)**<br>Habilita ou desabilita o calendário, isso não se refere a interação de seleção de dias, mas sim em interagir com o calendário de forma geral, incluindo navegação. Qunado passado o valor false o calendário ficará com a cor enfraquecida indicando que não há como interagir.

**clearSelection()**<br>Limpa toda seleção do calendário.


### Alteração de cores

Para customizar as cores acesse o elemento que deseja alterar na propriedade **colors** e atribua uma UIColor:

**calendarView.colors.monthTitle**<br>
**calendarView.colors.headerBackground**<br>
**calendarView.colors.weekTitles**<br>
**calendarView.colors.weekBackground**<br>
**calendarView.colors.sundayColor**<br>
**calendarView.colors.daySelected**<br>
**calendarView.colors.daySelectedBackground**<br>
**calendarView.colors.daysIntervalBackground**<br>
**calendarView.colors.calendarBackground**<br>
**calendarView.colors.daysOfMonth**<br>
**calendarView.colors.otherDays**<br>

<img width="427" alt="Captura de Tela 2024-04-10 às 14 55 29" src="https://github.com/emersonmluz/CalendarView/assets/111133275/ca21a21b-4332-4996-983b-ebb287af59ec">
