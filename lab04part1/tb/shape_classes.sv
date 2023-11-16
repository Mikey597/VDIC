
typedef struct {
    real x;
    real y;
}points_t;

typedef points_t pts_t[$];

virtual class shape_c;
    protected string name;
    protected points_t points[$];

    function new(string n, points_t p[$]);
        name = n;
        points = p;
    endfunction //new()

    function void print();
        $display("This is: %0s", name);
        foreach(points[i])
            $display("  (%0.2f, %0.2f)", points[i].x, points[i].y);
        if(name == "circle") $display("radius: %0.2f",get_radius());
        if(name == "polygon") $display("Area is: can not be calculated for generic polygon.");
        else $display("Area is: %0.2f",get_area());
    endfunction

    pure virtual function real get_area();

    virtual function real get_radius();
		$fatal(1,"Cant call radius from shape_c");
	endfunction	

endclass //shape_c

class polygon_c extends shape_c;

    protected string name;
    protected points_t points [$];

    function new(string n, points_t p[$]);
        super.new(n, p);
        name = n;

        if(p.size() >= 4) 
            foreach(p[i]) points.push_back(p[i]);    
        else $fatal(1,{"That is not a polygon"});    

    endfunction //new()

    function real get_area();
        `ifdef DEBUG
        $display("siema");
                foreach(points[i]) begin
                    $display("points %0.2f",points[i].x);
                    $display("points %0.2f",points[i].y);
                end
        `endif      
    endfunction

endclass //polygon_c extends shape_c

class rectangle_c extends shape_c;

    protected string name;
    protected points_t points [$];

    function new(string n, points_t p[$]);

        super.new(n, p);
        name = n;

        if(p.size() >= 4) 
            foreach(p[i]) points.push_back(p[i]);
        else  $fatal(1,{"Thats not a rectangle"});

    endfunction //new()

    function real get_area();
        //length of a 
        real a = $sqrt((points[1].x - points[0].x)**2 + (points[1].y - points[0].y)**2);
        //length of b
        real b = $sqrt((points[3].x - points[2].x)**2 + (points[3].y - points[2].y)**2);
        `ifdef DEBUG
        $display("siema");
                foreach(points[i]) begin
                    $display("points %0.2f",points[i].x);
                    $display("points %0.2f",points[i].y);
                end
        `endif              
        return a*b;
    endfunction

endclass //rectangle_c extends shape_c

class triangle_c extends shape_c;

    protected string name;
    protected points_t points [$];

    function new(string n, points_t p[$]);

        super.new(n, p);
        name = n;

        if(p.size() >= 3)
            foreach(p[i]) points.push_back(p[i]);
        else $fatal(1,{"This is not a triangle"});
     
    endfunction //new()

    function real get_area();
        real area = 0.5*(points[0].x*(points[1].y-points[2].y) + points[1].x*(points[2].y-points[0].y) + points[2].x*(points[0].y-points[1].y));
        `ifdef DEBUG
        $display("siema");
                foreach(points[i]) begin
                    $display("points %0.2f",points[i].x);
                    $display("points %0.2f",points[i].y);
                end
        `endif        
        return area;
    endfunction

endclass //triangle_c extends shape_c

class circle_c  extends shape_c;

    protected string name;
    protected points_t points [$];
    protected real r;

    function new(string n, points_t p[$]);

        super.new(n, p);
        name = n;

        if(p.size() >= 2) 
            foreach(p[i]) points.push_back(p[i]);
        else $fatal(1,{"This is not a circle"});
    
    endfunction //new()

    function real get_radius();
        r = $sqrt((points[1].x-points[0].x)**2 + (points[1].y-points[0].y)**2);
        return r;
    endfunction

    function real get_area();
	    real area;
        `ifdef DEBUG
        $display("siema");
                foreach(points[i]) begin
                    $display("points %0.2f",points[i].x);
                    $display("points %0.2f",points[i].y);
                end
        `endif              
        r = get_radius();
        area = 3.14*(r**2);
        return area;
    endfunction

endclass //circle_c  extends shape_c

class shape_factory;

    static function shape_c make_shape(string shape, points_t points[$]);

        polygon_c polygon;
        rectangle_c rectangle;
        triangle_c triangle;
        circle_c circle;

        case (shape) 
            "polygon" :   begin
                            polygon = new(shape, points);
                            return polygon;
                          end

            "rectangle" : begin
                            rectangle = new(shape, points);
                            return rectangle;
                          end

            "triangle" :  begin
                            triangle = new(shape, points);
                            return triangle;
                          end

            "circle" :    begin
                            circle = new(shape, points);
                            return circle;
                          end

            default : 
                $error({"Theat is not a shape: ", shape});
            endcase 

    endfunction
endclass //shape_factory

class shape_reporter #(type T = shape_c);

    protected static T storage [$];

    static function void store_shape(T l);

        storage.push_back(l);

    endfunction 

    static function void report_shapes();

        foreach(storage[i]) storage[i].print();

    endfunction 

endclass //shape_reporter #(type T = shape_c)

// module top;

//     initial begin : main_loop
//         // ####################################### DECLARATIONS #######################################
//         // --- File IO defines ---
//         pts_t lines_of_pts[$];
//         points_t points[$];

//         int fd;     // File descriptor
//         string line;                
//         int offset, offset_prev;
//         int eol;
//         int x_y_index;
//         int space_cnt;
//         string slice;

//         // --- Objects of shape classes --- 
//         shape_c shape;
//         polygon_c polygon_h;
//         rectangle_c rectangle_h;
//         triangle_c triangle_h;
//         circle_c circle_h;

//         // #################################### READING THE TXT FILE ####################################

//         // Needed to specify the absolute path 
//         fd = $fopen("/student/mkarelus/VDIC/lab04part1/tb/lab04part1_shapes.txt", "r");
//         if(fd == 0) $fatal(1, {"File was not opened succesfully : ", fd});


//         while (!$feof(fd)) begin
//             // Read file line by line
//             $fgets(line, fd);

//             x_y_index = 0;  
//             offset = 0;
//             eol = line.len()-1;

//             while (offset <= eol) begin
//                 // Scan each pair of points and pack them into the queue
//                 $sscanf(line.substr(offset,eol), "%f %f", points[x_y_index].x, points[x_y_index].y);

//                 space_cnt = 0;
//                 offset += 1;
//                 slice = line.substr(offset,eol);
                
//                 // Calculate string offset between values by searching for next two spaces
//                 foreach(slice[i]) begin
//                     if(slice[i] == " ") space_cnt +=1;
//                     // Exception needed for the last pair
//                     if((space_cnt == 2) || ((space_cnt != 2) && (i == slice.len()-1))) begin 
//                         x_y_index++;
//                         offset += i;
//                         break;
//                     end
//                 end
//                 if((offset_prev == offset-1) || (eol <= offset+1)) break; // workaround 
//                 offset_prev = offset;
//             end
//             lines_of_pts.push_back(points);
//             points.delete();
//         end

//         $fclose(fd);

// `ifdef DEBUG
//         foreach(lines_of_pts[i]) begin
//             $display("Line %0d",i);
//             foreach(lines_of_pts[i][j])
//                 $display(" points: X=%0.2f  Y=%0.2f",lines_of_pts[i][j].x, lines_of_pts[i][j].y);
//         end
// `endif

//         // #################################### CALLING MAKE METHOD ####################################

//         if(!$cast(polygon_h ,shape_factory::make_shape("polygon", lines_of_pts[0])))
//             $fatal(1, "Failed to cast shape factory result to polygon_h");
//         shape_reporter#(polygon_c)::store_shape(polygon_h);

//         if(!$cast(rectangle_h ,shape_factory::make_shape("rectangle", lines_of_pts[1])))
//             $fatal(1, "Failed to cast shape factory result to rectangle_h");
//         shape_reporter#(rectangle_c)::store_shape(rectangle_h);
        
//         if(!$cast(rectangle_h ,shape_factory::make_shape("rectangle", lines_of_pts[2])))
//             $fatal(1, "Failed to cast shape factory result to rectangle_h");
//         shape_reporter#(rectangle_c)::store_shape(rectangle_h);

//         if(!$cast(triangle_h ,shape_factory::make_shape("triangle", lines_of_pts[3])))
//             $fatal(1, "Failed to cast shape factory result to triangle_h");
//         shape_reporter#(triangle_c)::store_shape(triangle_h);

//         if(!$cast(triangle_h ,shape_factory::make_shape("triangle", lines_of_pts[4])))
//             $fatal(1, "Failed to cast shape factory result to triangle_h");
//         shape_reporter#(triangle_c)::store_shape(triangle_h);
        
//         if(!$cast(circle_h ,shape_factory::make_shape("circle", lines_of_pts[5])))
//             $fatal(1, "Failed to cast shape factory result to circle_h");
//         shape_reporter#(circle_c)::store_shape(circle_h);

//         if(!$cast(circle_h ,shape_factory::make_shape("circle", lines_of_pts[6])))
//             $fatal(1, "Failed to cast shape factory result to circle_h");
//         shape_reporter#(circle_c)::store_shape(circle_h);

//         // ################################### CALLING REPORT METHOD ####################################
        
//         shape_reporter#(polygon_c)::report_shapes();
//         shape_reporter#(rectangle_c)::report_shapes();
//         shape_reporter#(triangle_c)::report_shapes();
//         shape_reporter#(circle_c)::report_shapes();

//         $finish();

//     end : main_loop

// endmodule : top
