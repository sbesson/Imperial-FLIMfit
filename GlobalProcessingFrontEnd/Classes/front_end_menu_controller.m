classdef front_end_menu_controller < handle
    
    properties
        
        %%%%%%%%%%%%%%%%%%%%%%% OMERO                
        
        menu_OMERO_Set_Dataset;        
        menu_OMERO_Set_Plate;        
        menu_OMERO_Load_FLIM_Data;
        menu_OMERO_Load_FLIM_Dataset; 
        menu_OMERO_Load_IRF_FOV;
        menu_OMERO_Load_IRF_annot;            
        menu_OMERO_Load_Background;            
        menu_OMERO_Export_Fitting_Results;    
        menu_OMERO_Export_Fitting_Settings;            
        menu_OMERO_Import_Fitting_Settings;
            menu_OMERO_Reset_Logon;  
            menu_OMERO_Load_IRF_WF_gated;
            menu_OMERO_Load_Background_form_Dataset;
            menu_OMERO_Load_tvb_from_Image;
            menu_OMERO_Load_tvb_from_Dataset;
            menu_OMERO_Switch_User
            
        menu_OMERO_Working_Data_Info;
        
        omero_data_manager;                
        
        %%%%%%%%%%%%%%%%%%%%%%% OMERO                        
                        
        menu_file_new_window;
        
        menu_file_load_single;
        menu_file_load_widefield;
        menu_file_load_tcspc;
        
        menu_file_load_single_pol;
        menu_file_load_tcspc_pol;
        
        menu_file_load_acceptor;
        
        menu_file_reload_data;
        
        menu_file_save_dataset;
        menu_file_save_raw;
        
        menu_file_export_decay;
        menu_file_export_decay_series;
        
        menu_file_set_default_path;
        menu_file_recent_default
        
        menu_file_load_raw;
        
        menu_file_load_data_settings;
        menu_file_save_data_settings;
        
        menu_file_open_fit;
        menu_file_save_fit;
        
        menu_file_export_plots;
        menu_file_export_gallery;
        menu_file_export_hist_data;
        
        menu_file_import_plate_metadata;
        
        menu_file_export_fit_table;
        
        menu_file_import_fit_params;
        menu_file_export_fit_params;
        
        menu_file_import_fit_results;
        menu_file_export_fit_results;
        
        
        menu_irf_load;
        menu_irf_image_load;
        menu_irf_set_delta;
        
        menu_irf_estimate_t0;
        menu_irf_estimate_g_factor;
        menu_irf_estimate_background;
        %menu_irf_set_rectangular;
        %menu_irf_set_gaussian;
        menu_irf_recent;
        
        menu_background_background_load;
        menu_background_background_load_series;
        
        menu_background_tvb_load;
        menu_background_tvb_use_selected;
        
        menu_segmentation_manual;
        menu_segmentation_yuriy;
        
        menu_tools_photon_stats;
        menu_tools_estimate_irf;
        menu_tools_create_irf_shift_map;
        menu_tools_create_tvb_intensity_map;

        menu_view_data
        menu_view_plots;
        menu_view_hist_corr;
        menu_view_chi2_display;
        
        menu_test_test1;
        menu_test_test2;
        menu_test_test3;
        menu_test_unload_dll;
        
        menu_help_bugs;
        menu_help_tracker;
        
        menu_batch_batch_fitting;
        
        data_series_list;
        data_series_controller;
        data_decay_view;
        fit_controller;
        fitting_params_controller;
        plot_controller;
        hist_controller;
        data_masking_controller;
        
        recent_irf;
        recent_default_path;

        default_path;

    end
    
    properties(SetObservable = true)

        recent_data;
    end
    
    
    methods
        function obj = front_end_menu_controller(handles)
            assign_handles(obj,handles);
            set_callbacks(obj);
            try
                obj.default_path = getpref('GlobalAnalysisFrontEnd','DefaultFolder');
            catch e
                addpref('GlobalAnalysisFrontEnd','DefaultFolder','C:\')
                obj.default_path = 'C:\';
            end
            
            try
                obj.recent_data = getpref('GlobalAnalysisFrontEnd','RecentData');
            catch %#ok
                addpref('GlobalAnalysisFrontEnd','RecentData',{})
                obj.recent_data = [];
            end
            
            try
                obj.recent_irf = getpref('GlobalAnalysisFrontEnd','RecentIRF');
            catch e
                addpref('GlobalAnalysisFrontEnd','RecentIRF',{})
                obj.recent_irf = {};
            end
            
            try
                obj.recent_default_path = getpref('GlobalAnalysisFrontEnd','RecentDefaultPath');
            catch e
                addpref('GlobalAnalysisFrontEnd','RecentDefaultPath',{})
                obj.recent_default_path = {};
            end
            
            % obj.update_recent_irf_list(); % YA ????? !!!!!!
            
            obj.update_recent_default_list();
            
        end
        
        function set_callbacks(obj)
            
             mc = metaclass(obj);
             obj_prop = mc.Properties;
             obj_method = mc.Methods;
             
             
             % Search for properties with corresponding callbacks
             for i=1:length(obj_prop)
                prop = obj_prop{i}.Name;
                if strncmp(prop,'menu_',5)
                    method = [prop '_callback'];
                    matching_methods = findobj([obj_method{:}],'Name',method);
                    if ~isempty(matching_methods)               
                        eval(['set(obj.' prop ',''Callback'',@obj.' method ')' ]);
                    end
                end          
             end
             
        end
        
                       
        function set.recent_data(obj,recent_data)
            obj.recent_data = recent_data;
            setpref('GlobalAnalysisFrontEnd','RecentData',recent_data);
        end
        
        function add_recent_data(obj,type,path)
            obj.recent_data = {obj.recent_data; [type, path]};
        end

        function add_recent_irf(obj,path)
            if ~any(strcmp(path,obj.recent_irf))
                obj.recent_irf = [path; obj.recent_irf];
            end
            if length(obj.recent_irf) > 20
                obj.recent_irf = obj.recent_irf(1:20);
            end
            setpref('GlobalAnalysisFrontEnd','RecentIRF',obj.recent_irf);
            obj.update_recent_irf_list();
        end
        
        function update_recent_irf_list(obj)
            
            function menu_call(file)
                 obj.data_series_controller.data_series.load_irf(file);
            end
            
            if ~isempty(obj.recent_irf)
                names = create_relative_path(obj.default_path,obj.recent_irf);

                delete(get(obj.menu_irf_recent,'Children'));
                add_menu_items(obj.menu_irf_recent,names,@menu_call,obj.recent_irf)
            end
        end
        
        function update_recent_default_list(obj)
            function menu_call(path)
                 obj.default_path = path;
                 setpref('GlobalAnalysisFrontEnd','DefaultFolder',path);
            end
            
            if ~isempty(obj.recent_default_path)
                names = obj.recent_default_path;

                delete(get(obj.menu_file_recent_default,'Children'));
                add_menu_items(obj.menu_file_recent_default,names,@menu_call,obj.recent_default_path)
            end
        end
        
        
        %------------------------------------------------------------------
        % Default Path
        %------------------------------------------------------------------
        function menu_file_new_window_callback(obj,~,~)
            GlobalProcessing();
        end
        
        %------------------------------------------------------------------
        % Default Path
        %------------------------------------------------------------------
        function menu_file_set_default_path_callback(obj,~,~)
            path = uigetdir(obj.default_path,'Select default path');
            if path ~= 0
                obj.default_path = path; 
                
                if ~any(strcmp(path,obj.recent_default_path))
                    obj.recent_default_path = [path; obj.recent_default_path];
                end
                if length(obj.recent_default_path) > 20
                    obj.recent_default_path = obj.recent_default_path(1:20);
                end
                setpref('GlobalAnalysisFrontEnd','RecentDefaultPath',obj.recent_default_path);
                
                setpref('GlobalAnalysisFrontEnd','DefaultFolder',path);
                obj.update_recent_default_list();
                obj.update_recent_irf_list();
            end
        end
                
        %------------------------------------------------------------------
        % OMERO
        %------------------------------------------------------------------
        function menu_OMERO_Set_Dataset_callback(obj,~,~)            
            infostring = obj.omero_data_manager.Set_Dataset();
            if ~isempty(infostring)
                set(obj.menu_OMERO_Working_Data_Info,'Label',infostring,'ForegroundColor','blue');
            end;
        end                        
        %------------------------------------------------------------------        
        function menu_OMERO_Load_FLIM_Data_callback(obj,~,~)
            obj.data_series_controller.data_series = flim_data_series();
            obj.omero_data_manager.Load_FLIM_Data(obj.data_series_controller.data_series);
            notify(obj.data_series_controller,'new_dataset');
        end                                  
        %------------------------------------------------------------------        
        function menu_OMERO_Load_FLIM_Dataset_callback(obj,~,~)
            obj.data_series_controller.data_series = flim_data_series();            
            obj.omero_data_manager.Load_FLIM_Dataset(obj.data_series_controller.data_series);
            notify(obj.data_series_controller,'new_dataset');
        end                    
        %------------------------------------------------------------------ 
        function menu_OMERO_Load_IRF_FOV_callback(obj,~,~)
            obj.omero_data_manager.Load_IRF_FOV(obj.data_series_controller.data_series);
        end                    
        %------------------------------------------------------------------
        function menu_OMERO_Load_IRF_annot_callback(obj,~,~)
            obj.omero_data_manager.Load_IRF_annot(obj.data_series_controller.data_series);
        end                    
        %------------------------------------------------------------------
        function menu_OMERO_Load_Background_callback(obj,~,~)                                     
            tempfilename = obj.omero_data_manager.load_imagefile();
            if isempty(tempfilename), return, end;                                    
            try 
                obj.data_series_controller.data_series.load_background(tempfilename);                          
            catch e, 
                errordlg([e.identifier ' : ' e.message]), 
            end                        
        end                            
        %------------------------------------------------------------------
        function menu_OMERO_Export_Fitting_Results_callback(obj,~,~)
            obj.omero_data_manager.Export_Fitting_Results(obj.fit_controller,obj.data_series_controller.data_series);
        end                    
        %------------------------------------------------------------------        
        function menu_OMERO_Export_Fitting_Settings_callback(obj,~,~)
            obj.omero_data_manager.Export_Fitting_Settings(obj.fitting_params_controller);
        end                    
        %------------------------------------------------------------------
        function menu_OMERO_Import_Fitting_Settings_callback(obj,~,~)
            obj.omero_data_manager.Import_Fitting_Settings(obj.fitting_params_controller);
        end                    
        %------------------------------------------------------------------
        function menu_OMERO_Set_Plate_callback(obj,~,~)
            infostring = obj.omero_data_manager.Set_Plate();
            if ~isempty(infostring)
                set(obj.menu_OMERO_Working_Data_Info,'Label',infostring,'ForegroundColor','blue');            
            end;
        end     
        %------------------------------------------------------------------        
        function menu_OMERO_Reset_Logon_callback(obj,~,~)
            obj.omero_data_manager.Omero_logon();
        end
        %------------------------------------------------------------------        
        function menu_OMERO_Load_IRF_WF_gated_callback(obj,~,~)
            obj.omero_data_manager.Load_IRF_WF_gated(obj.data_series_controller.data_series);
        end
        %------------------------------------------------------------------        
        function menu_OMERO_Load_Background_form_Dataset_callback(obj,~,~)
            obj.omero_data_manager.Load_Background_form_Dataset(obj.data_series_controller.data_series);
        end
        %------------------------------------------------------------------        
        function menu_OMERO_Load_tvb_from_Image_callback(obj,~,~)
            obj.omero_data_manager.Load_tvb_from_Image(obj.data_series_controller.data_series);
        end
        %------------------------------------------------------------------        
        function menu_OMERO_Load_tvb_from_Dataset_callback(obj,~,~)
            obj.omero_data_manager.Load_tvb_from_Dataset(obj.data_series_controller.data_series);
        end                              
        %------------------------------------------------------------------        
        function menu_OMERO_Switch_User_callback(obj,~,~)
            delete([ pwd '\' obj.omero_data_manager.omero_logon_filename ]);
            obj.omero_data_manager.Omero_logon();
        end        
        %------------------------------------------------------------------
        % OMERO
        %------------------------------------------------------------------                                
                                        
        %------------------------------------------------------------------
        % Load Data
        %------------------------------------------------------------------
        function menu_file_load_single_callback(obj,~,~)
            [file,path] = uigetfile('*.*','Select a file from the data',obj.default_path);
            if file ~= 0
                obj.data_series_controller.load_single([path file]); 
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
        end
        
        function menu_file_load_widefield_callback(obj,~,~)
            folder = uigetdir(obj.default_path,'Select the folder containing the datasets');
            if folder ~= 0
                obj.data_series_controller.load_data_series(folder,'widefield'); 
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
        end
        
        function menu_file_load_tcspc_callback(obj,~,~)
            folder = uigetdir(obj.default_path,'Select the folder containing the datasets');
            if folder ~= 0
                obj.data_series_controller.load_data_series(folder,'TCSPC');
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
        end
        
        function menu_file_load_single_pol_callback(obj,~,~)
            [file,path] = uigetfile('*.*','Select a file from the data',obj.default_path);
            if file ~= 0
                obj.data_series_controller.load_single([path file],true); 
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
                end
        
        function menu_file_load_tcspc_pol_callback(obj,~,~)
            folder = uigetdir(obj.default_path,'Select the folder containing the datasets');
            if folder ~= 0
                obj.data_series_controller.load_data_series(folder,'TCSPC',true);
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
        end
        
        function menu_file_reload_data_callback(obj,~,~)
            obj.data_series_controller.data_series.reload_data;
        end
        
        function menu_file_load_acceptor_callback(obj,~,~)
            folder = uigetdir(obj.default_path,'Select the folder containing the datasets');
            if folder ~= 0
                obj.data_series_controller.data_series.load_acceptor_images(folder);
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
        end
        
        %------------------------------------------------------------------
        % Export Data Settings
        %------------------------------------------------------------------
        function menu_file_save_data_settings_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_series_controller.data_series.save_data_settings([pathname filename]);         
            end
        end
        
        function menu_file_load_data_settings_callback(obj,~,~)
            [filename, pathname] = uigetfile({'*.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_series_controller.data_series.load_data_settings([pathname filename]);         
            end
        end

        %------------------------------------------------------------------
        % Export Data
        %------------------------------------------------------------------
        function menu_file_save_dataset_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.hdf5', 'HDF5 File (*.hdf5)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_series_controller.data_series.save_data_series([pathname filename]);         
            end
        end
        
        function menu_file_save_raw_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.raw', 'Raw File (*.raw)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_series_controller.data_series.save_raw_data([pathname filename]);         
            end
        end
        
        function menu_file_load_raw_callback(obj,~,~)
            [filename, pathname] = uigetfile({'*.raw', 'Raw File (*.raw)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_series_controller.load_raw([pathname filename]);         
            end
        end
        
        %------------------------------------------------------------------
        % Export Decay
        %------------------------------------------------------------------
        function menu_file_export_decay_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.txt', 'TXT File (*.txt)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.data_decay_view.update_display([pathname filename]);
            end
        end
        
        function menu_file_export_decay_series_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.txt', 'TXT File (*.txt)'},'Select file postfix',obj.default_path);
            if filename ~= 0
                obj.data_decay_view.update_display([pathname filename],'all');
            end
        end
        
        %------------------------------------------------------------------
        % Import/Export Fit Results
        %------------------------------------------------------------------
        function menu_file_export_fit_results_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.hdf5', 'HDF5 File (*.hdf5)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.fit_controller.save_fit_result([pathname filename]);         
            end
        end

        function menu_file_import_fit_results_callback(obj,~,~)
            [filename, pathname] = uigetfile({'*.hdf5', 'HDF5 File (*.hdf5)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.fit_controller.load_fit_result([pathname filename]);           
            end
        end
        
        %------------------------------------------------------------------
        % Import/Export Fit Parameters
        %------------------------------------------------------------------
        function menu_file_export_fit_params_callback(obj,~,~)
            [filename, pathname] = uiputfile({'fit_parameters.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.fitting_params_controller.save_fitting_params([pathname filename]);         
            end
        end

        function menu_file_import_fit_params_callback(obj,~,~)
            [filename, pathname] = uigetfile({'*.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.fitting_params_controller.load_fitting_params([pathname filename]);           
            end
        end

        %------------------------------------------------------------------
        % Export Fit Table
        %------------------------------------------------------------------
        function menu_file_export_fit_table_callback(obj,~,~)
            [filename, pathname] = uiputfile({'*.csv', 'CSV File (*.csv)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.fit_controller.save_param_table([pathname filename]);
            end
        end
        
        
        function menu_file_import_plate_metadata_callback(obj,~,~)
            [file,path] = uigetfile({'*.xls;*.xlsx','Excel Files'},'Select the metadata file',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.import_plate_metadata([path file]);
            end
        end
        
        
        %------------------------------------------------------------------
        % IRF
        %------------------------------------------------------------------
        function menu_irf_load_callback(obj,~,~)
            [file,path] = uigetfile('*.*','Select a file from the irf',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.load_irf([path file]);
                % obj.add_recent_irf([path file]); % ?!!
            end
        end
        
        function menu_irf_image_load_callback(obj,~,~)
            [file,path] = uigetfile('*.*','Select a file from the irf',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.load_irf([path file],true);
            end
        end
        
        function menu_irf_set_delta_callback(obj,~,~)
            obj.data_series_controller.data_series.set_delta_irf();
        end
        
        function menu_irf_set_rectangular_callback(obj,~,~)
            width = inputdlg('IRF Width','IRF Width',1,{'500'});
            width = str2double(width);
            obj.data_series_controller.data_series.set_rectangular_irf(width);
        end
        
        function menu_irf_set_gaussian_callback(obj,~,~)
            width = inputdlg('IRF Width','IRF Width',1,{'500'});
            width = str2double(width);
            obj.data_series_controller.data_series.set_gaussian_irf(width);
        end
        
        function menu_irf_estimate_background_callback(obj,~,~)
            obj.data_series_controller.data_series.estimate_irf_background();
        end
        
        function menu_irf_estimate_t0_callback(obj,~,~)
            obj.data_masking_controller.t0_guess_callback();    
        end
        
        function menu_irf_estimate_g_factor_callback(obj,~,~)
            obj.data_masking_controller.g_factor_guess_callback();    
        end
        
        
        %------------------------------------------------------------------
        % Background
        %------------------------------------------------------------------
        function menu_background_background_load_callback(obj,~,~)
            [file,path] = uigetfile('*.tif','Select a background image file',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.load_background([path file]);    
            end
        end
        
        function menu_background_background_load_series_callback(obj,~,~)
            [path] = uigetdir(obj.default_path,'Select a folder of background images');
            if path ~= 0
                obj.data_series_controller.data_series.load_background(path);    
            end
        end
        
        function menu_background_tvb_load_callback(obj,~,~)
            [file,path] = uigetfile('*.*','Select a TVB file',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.load_tvb([path file]);    
            end
        end
        
        function menu_background_tvb_I_map_load_callback(obj,~,~)
            [file,path] = uigetfile('*.xml','Select a TVB intensity map file',obj.default_path);
            if file ~= 0
                obj.data_series_controller.data_series.load_background([path file]);    
            end
        end
        
        function menu_background_tvb_use_selected_callback(obj,~,~)
           obj.data_masking_controller.tvb_define_callback();    
        end
        
        
        %------------------------------------------------------------------
        % Segmentation
        %------------------------------------------------------------------
        function menu_segmentation_yuriy_callback(obj,~,~)
            yuiry_segmentation_manager(obj.data_series_controller);
        end
        
        %------------------------------------------------------------------
        % Batch Fit
        %------------------------------------------------------------------
        function menu_batch_batch_fitting_callback(obj,~,~)
            folder = uigetdir(obj.default_path,'Select the folder containing the datasets');
            if folder ~= 0
                settings_file = tempname;
                fit_params = obj.fitting_params_controller.fit_params;
                obj.data_series_controller.data_series.save_dataset_indextings(settings_file);
                batch_fit(folder,'widefield',settings_file,fit_params);
                if strcmp(obj.default_path,'C:\')
                    obj.default_path = path;
                end
            end
            
        end
        
        
        function menu_tools_photon_stats_callback(obj,~,~)
            d = obj.data_series_controller.data_series;
            
            % get data without smoothing
            d.compute_tr_data(false,true);
            
             data = d.cur_tr_data;
            [N,Z] = determine_photon_stats(data);
            
            d.counts_per_photon = N;
            d.background_value = d.background_value + Z;
            
            d.compute_tr_data(true,true);

        end
        
        function menu_tools_estimate_irf_callback(obj,~,~)
            d = obj.data_series_controller.data_series;
            estimate_irf(d.tr_t_irf,d.tr_irf);
        end
        
        
        %------------------------------------------------------------------
        % Views
        %------------------------------------------------------------------
        
        function menu_view_chi2_display_callback(obj,~,~)
            chi2_display(obj.fit_controller);
        end
        
        function menu_test_test1_callback(obj,~,~)
            regression_testing(obj);
            %polarisation_testing(obj.data_series_controller.data_series,obj.default_path);
        end
        
        function menu_tools_create_irf_shift_map_callback(obj,~,~)
            mask=obj.data_masking_controller.roi_controller.roi_mask;
            irf_data = obj.data_series_controller.data_series.generate_t0_map(mask,1);
            
            [filename, pathname] = uiputfile({'*.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0

                serialise_object(irf_data,[pathname filename],'flim_data_series');
            end
            
        end
        
        function menu_tools_create_tvb_intensity_map_callback(obj,~,~)
           
            mask=obj.data_masking_controller.roi_controller.roi_mask;
            irf_data = obj.data_series_controller.data_series.generate_tvb_I_map(mask,1);
            
            [filename, pathname] = uiputfile({'*.xml', 'XML File (*.xml)'},'Select file name',obj.default_path);
            if filename ~= 0

                serialise_object(irf_data,[pathname filename],'flim_data_series');
            end
            
        end
        
        function menu_test_test2_callback(obj,~,~)
            
            d = obj.data_series_controller.data_series;

            tr_acceptor = zeros(size(d.acceptor));

            [optimizer, metric] = imregconfig('multimodal'); 
            optimizer.MaximumIterations = 40;
            h = waitbar(0,'Aligning...');

            for i=1:d.n_datasets
            
                a = d.acceptor(:,:,i);
                intensity = d.integrated_intensity(i);
                try
                    [tr,t] = imregister2(a,intensity,'rigid',optimizer,metric);
                    dx = t.tdata.T(3,1:2);
                    dx = norm(dx);
                    disp(dx);
                    
                    if dx>200
                        tr = a;
                    end

                catch
                    tr = a;
                end
                
                tr_acceptor(:,:,i) = tr;
                
                %figure(13);
                %imagesc(tr_acceptor(:,:,i)); pause(1); imagesc(intensity);
                
                waitbar(i/d.n_datasets,h);
            end
            
            global acceptor;
            acceptor = tr_acceptor;
            %save('C:\Users\scw09\Documents\00 Local FLIM Data\2012-10-17 Rac COS Plate\acceptor_images.mat','acceptor');
            close(h);            
            
        end
        
        function menu_test_test3_callback(obj,~,~)
            file = 'c:\users\scw09\documents\data_serialization.h5';
            
            obj.data_series_controller.data_series.serialize(file);
            
            %{
            global fg fh;
            r = obj.fit_controller.fit_result;
            
            im = r.get_image(1,'tau_1');
            I = r.get_image(1,'I');
            dim = 2;
            color = {'b', 'r', 'm', 'g', 'k'};
            s = nanstd(im,0,dim);
            m = nanmean(im,dim);
            I = nanmean(I,dim);
            figure(fg);
            hold on;
            fh(end+1) = plot(s,color{length(fh)+1});
            ylim([0 500]);
            %}
        end
        
        
        function menu_test_unload_dll_callback(obj,~,~)
            if is64
                unloadlibrary('FLIMGlobalAnalysis_64');
            else
                unloadlibrary('FLIMGlobalAnalysis_32');
            end
        end
        
        function menu_file_export_plots_callback(obj, ~, ~)
            [filename, pathname, ~] = uiputfile( ...
                        {'*.tiff', 'TIFF image (*.tiff)';...
                         '*.pdf','PDF document (*.pdf)';...
                         '*.png','PNG image (*.png)';...
                         '*.eps','EPS level 1 image (*.eps)';...
                         '*.fig','Matlab figure (*.fig)';...
                         '*.*',  'All Files (*.*)'},...
                         'Select root file name',[obj.default_path '\fit']);

            if ~isempty(filename)
                obj.plot_controller.update_plots([pathname filename])
            end
        end
        
        function menu_file_export_all_callback(obj,~,~)
            
        end
        
        function menu_file_export_gallery_callback(obj, ~, ~)

            [filename, pathname, ~] = uiputfile( ...
                        {'*.tiff', 'TIFF image (*.tiff)';...
                         '*.pdf','PDF document (*.pdf)';...
                         '*.png','PNG image (*.png)';...
                         '*.eps','EPS level 1 image (*.eps)';...
                         '*.fig','Matlab figure (*.fig)';...
                         '*.*',  'All Files (*.*)'},...
                         'Select root file name',[obj.default_path '\fit']);

            if ~isempty(filename)
                obj.plot_controller.update_gallery([pathname filename])
            end
            
        end
        
        function menu_file_export_hist_data_callback(obj, ~, ~)
            [filename, pathname] = uiputfile({'*.txt', 'Text File (*.txt)'},'Select file name',obj.default_path);
            if filename ~= 0
                obj.hist_controller.export_histogram_data([pathname filename]);
            end
        end

        function menu_help_tracker_callback(obj, ~, ~)
            web('https://bitbucket.org/scw09/globalprocessing/issues','-browser');
        end

        function menu_help_bugs_callback(obj, ~, ~)
            web('https://bitbucket.org/scw09/globalprocessing/issues/new','-browser');
        end


    end
    
end
