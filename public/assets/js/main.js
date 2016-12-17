var App = {

    error_message:'',

    init: function () {
        App.disabling();
        $('.next-options').click(this.checkOptions);
        $('.form-options').submit(this.submitOptions);
        $('.guess-form').submit(this.submitGuess);
    },

    disabling: function () {
        $('.next-options').off('click');
        $('.guess-form').off('submit');
    },

    checkOptions:function(){
        if (App.checkName()) {
            App.normaliseInput('name-group', '.help-block');
            if ($('.name-group').css('display') != 'none'){
                $('.name-group').fadeOut("slow", function () {
                    $('.diff-group').fadeIn('slow', function () {
                        return false;
                    });
                });
            }else{
                return true;
            }
        }else{
            App.wrongInput('.name-group', '.help-block');
        }
    },

    checkName: function(){
        var input = $('#name').val();
        switch (true){
            case input.length < 3 || input.length > 20:
                App.error_message = 'Name should consists from 3-20 letters';
                break;
            case !/^[A-Za-z0-9]*$/.test(input):
                App.error_message = 'Name should consists from letters or numbers';
                break;
            default:
                App.error_message = '';
        }
        return App.error_message == '' ;
    },

    checkGuess: function () {
        return /^[0-6]{4}$/.test($('#code').val());
    },

    wrongInput: function(text_block, message){
        $(text_block).addClass('has-error has-danger');
        $(message).text(App.error_message)
    },

    normaliseInput:function(text_block, message){
        $(text_block).removeClass('has-error has-danger');
        $(message).text('');
    },

    submitOptions: function(event){
        event.preventDefault();
        if (App.checkOptions()){
            $(this).unbind('submit').submit();
        }
    },

    submitGuess:function(e){
        if (App.checkGuess()){
            return true;
        }else{
            $('#code').val('');
            App.error_message = 'Code must have 4 digits and numbers from 0-6';
            App.wrongInput('.guess-block', '.help-block');
            return false;
        }
    }
};

App.init();
