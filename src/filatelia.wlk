object nueveReinas {
	// La asociación filatélica	
	const asociados = []
	
	method mejorCotizado() = asociados.max{a=>a.cotizacionColeccion()} 
	
	method esComun(estampilla) = asociados.count{a=>a.tiene(estampilla)} > 10
}

class Coleccionista {
		
	const estampillas = []
	const paises = []
	
	method cotizacionColeccion() = estampillas.sum({e=>e.cotizacion()})
	
	//Solución inicial
	method tiene(estampilla) = estampillas.contains(estampilla)

	//Variante para considerar que tiene la estampilla buscada cuando forma parte de una hojita block
	method tiene2(estampilla) = estampillas.any{e=>e.corresponde(estampilla)}
	
	method leInteresa(estampilla) = not self.tiene(estampilla) and self.esPaisBuscado(estampilla.pais())
	
	method esPaisBuscado(pais) = paises.contains(pais)

	//Solución inicial  
	method cuantasTieneDe(pais) = estampillas.count({e=>e.pais()== pais})
	
	//Variante considerando que las Hojitas Block se cuentan como la cantidad de estampillas que contiene 
	method cuantasTieneDe2(pais) = estampillas.filter({e=>e.pais()== pais}).sum{e=>e.cantidad()}
	 
}

class Estampilla {
	
	var property valor = 0
	var property pais
	var property emision
	
	method cotizacion() {
		return 
			if(self.esFallada()) 
				1000000
			else 
				self.cotizacionBase() + self.adicionalAntiguedad().min(150)
	}

	method cotizacionBase() = self.valor() * pais.coeficiente()
	
	method adicionalAntiguedad() = 5 * (self.antiguedad()-100).max(0)
	
	method antiguedad() = tiempo.anioActual() - emision
	
	method esFallada() = not pais.fechaValida(emision)
	
	//Para la variante de considerar las estampillas que forman parte de una Hojita Block   
	//Cualquier estampilla se corresponde consigo misma. 
	method corresponde(estampilla) = estampilla == self   

	//Para la variante de contar la cantidad de estampillas que forman parte de una Hojita Block
	//Para cualquier estampilla, la cantidad es 1   
	method cantidad() = 1
}


class Conmemorativa inherits Estampilla {
	
	var motivo 
	
	override method cotizacionBase() = super() * self.aumentoConmemorativa()
	
	method aumentoConmemorativa() = if(motivo.contains("zarate")) 3 else 2
	
}

class HojitaBlock inherits Conmemorativa{
	const estampillas = []
	
	override method valor() = estampillas.sum{e=>e.valor()}
	
	override method esFallada() = estampillas.any{e=>e.emision()!= emision or e.pais()!= pais} or super()
	
	//Para la variante de considerar las estampillas que forman parte de una Hojita Block   
	override method corresponde(estampilla) = estampillas.contains(estampilla) or super(estampilla)
	
	//Para la variante de contar la cantidad de estampillas que forman parte de una Hojita Block
	override method cantidad() = estampillas.size()   
	
}

class Pais {
	
	var property coeficiente = 1 
	
	var property inicio = 1840 //Por default, la fecha de la primera estampilla del mundo
	var property fin = null //Por default, para representar países existentes en la actualidad.  
		
	method fechaValida(fecha) = self.fechaInicioValida(fecha) and self.fechaFinValida(fecha)
	
	method fechaInicioValida(fecha) = fecha >= inicio  
	method fechaFinValida(fecha) {
		if (fin == null) return true
		return fecha <= fin
	}
}

object tiempo {
	var property anioActual = 2020
	
	method pasoEltiempo(anios){
		anioActual = anioActual + anios
	}
}
