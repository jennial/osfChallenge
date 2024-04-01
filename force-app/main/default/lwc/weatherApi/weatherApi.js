import { LightningElement } from 'lwc';
import getWeatherData from '@salesforce/apex/WeatherConditionsAPIController.getWeatherData';

export default class WeatherApi extends LightningElement {
   city;
   weatherIcon;
   weatherText;

    handleCity(event){
        this.city = event.target.value;
    }
    handleGetWeather(event){
        getWeatherData({city:this.city}).then(
            response=>{
                let weatherParseData = JSON.parse(response);
                this.weatherIcon = weatherParseData.weather.icon;
                this.weatherText = weatherParseData.weather.description;
            }
        ).catch(error=>{
            this.weatherText = 'Error to find location';
            console.error('error', JSON.stringify(error));
        })
    }
}