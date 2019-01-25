# connecting select2 to the appropriate hooks:
#
# hard case: best_in_place's select
# source: https://gist.github.com/argent-smith/3835854
$ ->

  # first, find the mount point
  $('body').on 'best_in_place:activate', '.select2 > .best_in_place', ->

    # second, attach empty update() to `this` to screen the downstream calls
    # which otherwise will cause an error
    @update = ->

    # now unbind `blur` from the <select> and bind it to the downstream
    # best_in_place's handler; this prevents the immediate select2's
    # destruction since clicking on it would cause `blur` on the downstream
    # best_in_place
    $(@).find('select').select2({ allowClear: true })
      .unbind('blur').bind('blur', {editor: @}, BestInPlaceEditor.forms.select.blurHandler)
