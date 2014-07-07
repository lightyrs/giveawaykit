SG.UI.DataTables =

  _sg: _SG

  initialize: (table) ->
    @initEntriesTable() if table is 'entries'

  initEntriesTable: ->
    responsiveHelper = null
    breakpointDefinition =
      xlg: 1420
      lg: 1300
      md: 992
      sm: 768
      xs: 480
      xxs: 360
    tableContainer = @entriesTableEl()

    @dt = @entriesTableEl().dataTable
      bSort: true
      bProcessing: true
      bServerSide: true
      sAjaxSource: "#{@_sg.Paths.giveawayEntries}"
      aaSorting: [[@defaultSortIndex(), @defaultSortOrder()]]
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-12'<'text-center'p><'text-center'i>>>"
      sPaginationType: "full_numbers"
      aoColumnDefs: [
        { sClass: "wrap email", aTargets: [ 1 ] }
      ]
      bAutoWidth: false
      fnPreDrawCallback: ->
        unless responsiveHelper?
          responsiveHelper = new ResponsiveDatatablesHelper(tableContainer.dataTable(), breakpointDefinition)
      fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
        responsiveHelper.createExpandIcon(nRow)
      fnDrawCallback: (oSettings) ->
        responsiveHelper.respond()

    $("tbody").on "click", "tr", (e) ->
      $(this).find("span.responsiveExpander").trigger "click" if $(this).closest("table").hasClass("has-columns-hidden")

  defaultSortIndex: ->
    @entriesTableEl().find('th.default-sort').index()

  defaultSortOrder: ->
    @entriesTableEl().find('th.default-sort').data('default-sort-order') || 'asc'

  entriesTableEl: -> $('#entries_table')
