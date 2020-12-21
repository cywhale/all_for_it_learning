# Change the name to app.R and run
# copy text to clipboard: https://www.w3schools.com/howto/howto_js_copy_clipboard.asp
# read text from clipboard by Dan Miller:　https://twitter.com/data_nurse/status/1234412933876109314

library(shiny) 
library(shinyjs)
#library(V8)

jsCpclip <- "shinyjs.cpclip = function(){ 
               return navigator.clipboard.readText().then(function(text){ 
                 Shiny.onInputChange('clip_data', text);});
             }"
jsWrclip <- "shinyjs.wrclip = function myFunction(id) {
  var copyText = document.getElementById(id);
  copyText.select();
  copyText.setSelectionRange(0, 99999); //For mobile devices
  document.execCommand('copy');
  alert(copyText.value);
}"

ui <- fluidPage(
  useShinyjs(), 
  extendShinyjs(text = jsWrclip), 
  extendShinyjs(text = jsCpclip), 
  textInput("txtin", "Input: ", value=""),
  actionButton("wr_clip", "Copy to clipboard"), 
  hr(),
  actionButton("rd_clip", "Read clipboard"), 
  textOutput("clip_out")
)

server <- function(input, output, session) {
  onclick( "wr_clip", {
    js$wrclip("txtin")
  })
  onclick( "rd_clip", {
    js$cpclip()
  })
  
  observeEvent(input$clip_data, {
    output$clip_out <- renderText(input$clip_data)
  })
}

shinyApp(ui = ui, server = server)
