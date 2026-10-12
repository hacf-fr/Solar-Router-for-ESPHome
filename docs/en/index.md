# Solar Router for ESPHome

**Solar Router for ESPHome** is a DIY project aiming to provide specialized hardware device and software tailored for optimizing solar energy utilization. It performs real-time monitoring and intelligent surplus energy management to effectively channels excess solar energy to designated loads like water heaters or frost protection systems. 

Key features include a choice of dynamic energy routing algorithms (progressive, ON/OFF), power meter sources (local or remote ...), regulators (with triac or relay ... ), and a seamless integration with [HomeAssistant](http://home-assistant.io) via [ESPHome](http://esphome.io) firmware. 

This component enables users to effortlessly monitor and control the router's functionality within the HomeAssistant ecosystem, facilitating streamlined energy management and automation.

!!! danger "Important Notice"
    This project involves working with high voltage (110 or 230 volts), which can be hazardous.  
    Please read the [disclaimer](disclaimer.md) before proceeding with the **Solar Router for ESPHome** project. 

!!! tips "Extended capabilities with Home Assistant sensors"

    **Solar Router for ESPHome** is nativelly compatible with some well known power meter of the market (See Power Meter chapter in the left menu). The ***power meter [Home Assistant](power_meter_home_assistant.md)***, extends the source of measurement the any sensors of Home Assistant making it compatible with a huge number of power meters.

![SolarRouterClosed](images/SolarRouterClosed.png){width=350}
![Dashboard](images/SolarRouterInHomeAssistantDashboard.png){width=350}

