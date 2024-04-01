public with sharing class WeatherConditionsAPIController {
   @AuraEnabled
   public static String getWeatherData(String city){
        
        HttpRequest req = new HttpRequest();
        String apiKey = 'f848c244e44758f37218da6c1b68cbf0';
        req.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q='+city + '&appid=' + apiKey);
        req.setMethod('GET');
        HttpResponse res = new HttpResponse();
        Http ht = new Http();
        res = ht.send(req);
        System.debug(res.getBody());
        return res.getBody();
  
   }
}