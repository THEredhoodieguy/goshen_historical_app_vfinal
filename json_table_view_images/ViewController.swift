//
//  ViewController.swift
//  json_table_view_images


import UIKit
import CoreData
import Foundation

//Initial storage of data
var big_array = Array<Array<String>>()
//Final storage of data
var final_array = Array<Array<Array<String>>>()

var values_array = []

//Determines whether the commercial or residential array is being looked at
var comm_or_res = 1


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //var json_data_url = "http://www.kaleidosblog.com/tutorial/json_table_view_images.json"
    var data_url = "http://people.goshen.edu/~matthewwp/test.txt"
    var image_base_url = "http://www.kaleidosblog.com/tutorial/"
    
    
    var TableData:Array< datastruct > = Array < datastruct >()
    
    enum ErrorHandler:ErrorType
    {
        case ErrorFetchingResults
    }
    
    
    struct datastruct
    {
        var imageurl:String?
        var description:String?
        var image:UIImage? = nil
        
        init(add: NSDictionary)
        {
            imageurl = add["url"] as? String
            description = add["description"] as? String
        }
    }
    
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		final_array.append(Array<Array<String>>())
		final_array.append(Array<Array<String>>())
		
        tableview.dataSource = self
        tableview.delegate = self
        
        
        //get_data_from_url(data_url)
        data_request(data_url)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let data = final_array[comm_or_res][indexPath.row]
        
        
        cell.textLabel?.text = data[2]
        
        /*if (data.image == nil)
        {
            cell.imageView?.image = UIImage(named:"image.jpg")
            load_image(image_base_url + data.imageurl!, imageview: cell.imageView!, index: indexPath.row)
        }
        else
        {
            cell.imageView?.image = TableData[indexPath.row].image
        }*/
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return final_array[comm_or_res].count
    }
    
    
    
    
    
    
    
    func get_data_from_url(url:String)
    {
        
        
        let url:NSURL = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.extract_json(data!)
                return
            })
            
        }
        
        task.resume()
        
    }
    
    
    func extract_json(jsonData:NSData)
    {
        let json: AnyObject?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
        } catch {
            json = nil
            return
        }
        
            print(json)
            if let list = json as? NSArray
            {
                for (var i = 0; i < list.count ; i++ )
                {
                    if let data_block = list[i] as? NSDictionary
                    {
                        
                        TableData.append(datastruct(add: data_block))
                    }
                }
                
                do
                {
                    try read()
                }
                catch
                {
                }
                
                do_table_refresh()
                
            }
            
        
    }
    
    
    
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableview.reloadData()
            return
        })
    }
    
    
    func load_image(urlString:String, imageview:UIImageView, index:NSInteger)
    {
        
        let url:NSURL = NSURL(string: urlString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.downloadTaskWithURL(url) {
            (
            let location, let response, let error) in
            
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let imageData = NSData(contentsOfURL: location!)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                
                self.TableData[index].image = UIImage(data: imageData!)
                self.save(index,image: self.TableData[index].image!)
                
                imageview.image = self.TableData[index].image
                return
            })
            
            
        }
        
        task.resume()
        
        
    }
    
    
    
    
    func read() throws
    {
        
        do
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName: "Images")
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            for (var i=0; i < fetchedResults.count; i++)
            {
                let single_result = fetchedResults[i]
                let index = single_result.valueForKey("index") as! NSInteger
                let img: NSData? = single_result.valueForKey("image") as? NSData
                
                TableData[index].image = UIImage(data: img!)
        
            }
            
        }
        catch
        {
            print("error")
            throw ErrorHandler.ErrorFetchingResults
        }
        
    }
    
    func save(id:Int,image:UIImage)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Images",
            inManagedObjectContext: managedContext)
        let options = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        let newImageData = UIImageJPEGRepresentation(image,1)
        
        options.setValue(id, forKey: "index")
        options.setValue(newImageData, forKey: "image")
        
        do {
            try managedContext.save()
        } catch
        {
            print("error")
        }
        
    }
    
    func data_request(url_to_request: String)
    {
        
        let url:NSURL = NSURL(string: url_to_request)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = String(data: data!, encoding: NSUTF8StringEncoding)
            
            //print(dataString)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.extract_data(dataString!)
                return
            })

            
        }
        
        task.resume()
        
    }
    
    func extract_data(data:String)
    {
        var data_to_use = data
        if (data_to_use.rangeOfString("404 Not Found") != nil) {
            
            print("Page 404'd")
            
            //If get request does not return a valid page, read from the file
            
            if(file_exists()) {
                data_to_use = read_from_file()
            }
            else {
                write_to_file(beginning_text_string)
                data_to_use = beginning_text_string
            }
            
        }
        else {
            
            print("Page didn't 404")
            
            //If get request does return a valid page, write the latest version of the page to file
            write_to_file(data_to_use)
        }
        
        write_to_file(data_to_use)
        
        values_array = data_to_use.characters.split { $0 == "\n"}.map(String.init)
        
        for i in values_array {
            big_array.append(i.componentsSeparatedByString("|"))
        }
        filter_array()
    }
	
	func filter_array()
	{
		for i in big_array
		{
			if(i[0] == "Commercial District")
			{
				//If the item is a commercial district item, append it to the first array in the final_array
				final_array[0].append(i)
			}
			else if(i[0].rangeOfString("Residential District") != nil)
			{
				//If the item is a residential district item, append it to the second array in the final_array
				final_array[1].append(i)
			}
			//If the item does not fall into one of these two categories, it should not be in the final_array
		}
		
		print(final_array)
		do_table_refresh()
	}
    
    
}
