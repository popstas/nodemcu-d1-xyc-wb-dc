(function($, require){
    $(function(){
        $('#filename').val('test.lua');
        $('#content').val('print("test")');

        require.config({paths: {'vs': 'node_modules/monaco-editor/min/vs'}});
        require(['vs/editor/editor.main'], function () {
            var editor = monaco.editor.create($('#editor').get(0), {
                value: $('#content').val(),
                language: 'lua',
                theme: 'vs-dark',
                mouseWheelZoom: true,
                parameterHints: true,
                folding: true,
            });
        });

        $('.ota-form').ajaxForm({
            beforeSerialize: function(arr, form, options){
                var model = monaco.editor.getModels()[0];
                var content = model.getValue();
                console.log('content', content);
                $('[name="content"]', '.ota-form').val(content);
            },
            beforeSubmit: function(arr, $form, options){
                options.url = 'http://' + $('#hostname').val() + '/ota';
            }
        });
    });
})(jQuery, require);
