var GetItemInfo = function() {};

GetItemInfo.prototype = {
    
run: function(arguments) {
    arguments.completionFunction({ "currentUrl" : document.URL });
}
    
};

var ExtensionPreprocessingJS = new GetItemInfo;
