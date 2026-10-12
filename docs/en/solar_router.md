# Solar Router / Diverter

**Solar Router for [ESPHome](http://esphome.io)** has been designed to work with [Home Assistant](http://home-assistant.io) and it requires the installation of [ESPHome integration](https://www.home-assistant.io/integrations/esphome/).  

## Progressive regulation

![HA](images/SolarRouterInHomeAssistant.png){ align=left }
!!! note ""
    **Controls**
    
    * ***Activate Solar Routing***  
      Control if Solar routing should be activated or not
    * ***Down Reactivity***  
      How fast will be the solar routing when real_power is more than target_grid_exchange.
      From 1 to 100. 1 is the slowest, 100 is the fastest.
    * ***Up Reactivity***  
      How fast will be the solar routing when real_power is less than target_grid_exchange.
      From 1 to 100. 1 is the slowest, 100 is the fastest.
    * ***Router Level***  
      What is the current percentage of energy sent to the load by the overall router
      From 0 to 100. 0 means no energy diverted, 100 means all energy diverted.
    * ***Target grid exchange***  
      What is the target of energy exchanged with the grid.  
      &lt; 0 energy is sent to the grid  
      &gt; 0 energy is used from the grid
!!! note ""
    **Sensors**
    
    * ***Real Power***  
      Energy actually exchanged with the grid. Updated every secondes. 

<br>  
<br>  
<br>  

!!! note 
    When solar routing is deactivated, router level slider can be modified "by hand".  
    If you modify the router level state while the solar routing is enabled, the routing algorithm will immediately modify the value to meet target grid exchange level.

## ON/OFF regulation

![HA](images/SolarRouterONOFFInHomeAssistant.png){ align=left }
!!! note ""
    **Controls**
    
    * ***Activate Solar Routing***  
      Control if Solar routing should be activated or not
    * ***Router Level***  
      What is the current percentage of energy sent to the load by the overall router
      Either 0 OR 100. 0 means no energy diverted, 100 means all energy diverted.
    * ***Start power level***  
      Define the power level at which diversion has to start
    * ***Start tempo***  
      How long the start level has to be exceeded before diverting energy
    * ***Stop power level***  
      Define the power level at which diversion has to stop
    * ***Start tempo***  
      How long the stop level has to be reached before stopping diversion
!!! note ""
    **Sensors**
    
    * ***Real Power***  
      Energy actually exchanged with the grid. Updated every secondes.
    * ***Start Tempo***
      Counter defining when energy diversion has to start
    * ***Stop Tempo***
      Counter defining when energy diversion has to stop

<br>
<br>

!!! note 
    When solar routing is deactivated, router level slider can be modified "by hand".  
    If you modify the router level state while the solar routing is enabled, the routing algorithm will immediately modify the value to meet target grid exchange level.
