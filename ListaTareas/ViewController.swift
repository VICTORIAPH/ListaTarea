//
//  ViewController.swift
//  ListaTareas
//
//  Created by Victoria on 18/05/22.
//

import UIKit
//importamos coredata
import CoreData
class ViewController: UIViewController {

    @IBOutlet weak var tablaTareas: UITableView!
                    //el nombre Tarea es como se llama la entidad
        var listaTareas = [Tarea]()
        //referencia al contenedor de coredata
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        
        leerTareas()
        
    }
    
    @IBAction func nuevaTarea(_ sender: UIBarButtonItem) {
        
        
            var nombreTarea = UITextField()
                //PARA EL ALERTA
        
            let alerta = UIAlertController(title: "Nueva", message: "Tarea", preferredStyle: .alert)
                //creamos accion ACEPTAR
            let accionAcepatr = UIAlertAction(title: "Agregar", style: .default) { (_) in
                let nuevaTarea = Tarea(context: self.contexto)
                nuevaTarea.nombre = nombreTarea.text
                //cuando creamos nueva tarea inicializamos en false
                nuevaTarea.realizada = false
                
                //guardamos en nuestra lista tareas
                self.listaTareas.append(nuevaTarea)
                //llamando al metodo save
                self.guardar()
            }//accion accep
        alerta.addTextField {  textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe tu texto aqui"
                //guardamos ese texto
                nombreTarea = textFieldAlerta
            
        }
        //agregarle una accion al alerta
        alerta.addAction(accionAcepatr)
        present(alerta, animated: true )
      
    }
    func guardar() {
        do{
            try contexto.save()
            
        }catch{
            print(error.localizedDescription)

        }
        //para actualizar la info
        self.tablaTareas.reloadData()
    }
    func leerTareas()  {
        let solicitud : NSFetchRequest<Tarea> = Tarea.fetchRequest()
        do{
            listaTareas = try contexto.fetch(solicitud)
            
        }catch{
            print(error.localizedDescription)

        }
        //para actualizar la info
        self.tablaTareas.reloadData()
    
        
    }
        
    }
    


//agregamos extension
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        //extraer tarea
        let tarea = listaTareas[indexPath.row]
            //operador ternario para validar
            celda.textLabel?.text = tarea.nombre
            celda.textLabel?.textColor = tarea.realizada ? .purple : .blue
            celda.detailTextLabel?.text = tarea.realizada ? "completadas" : "Por completar"
        
            //MARCAR LA PALOMITA
            celda.accessoryType = tarea.realizada ? .checkmark : .none
                return celda
    }
    //para editar la tarea seleccionada
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //palomear la tarea(si esta palomeada quitarle la polimita[indexPath es lo que el usuario selecciono])
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
                        
        }else{
            
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
                                    
        }
        //EDITAR EN COREDATA
        listaTareas[indexPath.row].realizada = !listaTareas[indexPath.row].realizada
        //como realizamos cambio vamos a llamar el metodo guardar
        guardar()
        
        //Deseleccionar tarea
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //creamos variable alerta
              let accionEliminar = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
                let alertaDelete = UIAlertController(title: "Delete", message: "¿Are you sure?", preferredStyle: .alert)
                let accionAceptar = UIAlertAction(title: "Delete", style: .default) { _ in
              
               //eliminar del contexto
                self.contexto.delete(self.listaTareas[indexPath.row])
                //eliminar del lista
                self.listaTareas.remove(at: indexPath.row)
                self.guardar()
                 
                    
            }
                let cancelar = UIAlertAction(title: "Cancelar", style: .default)
                            
                alertaDelete.addAction(accionAceptar)
                alertaDelete.addAction(cancelar)
                self.present(alertaDelete, animated: true)
                        }//Let accionEliminar de la UIContextualAction
                        
                        accionEliminar.backgroundColor = .red
                        
                        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
}
