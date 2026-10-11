clc;
clear;
close all;

%% RETO 3: ALGORITMO DE CONTROL Y CARGAS
% Sistema inteligente de gestion energetica
% Generacion solar, eolica y control de bateria
% Capacidad de la bateria: 100 kWh

%% 1. DATOS DE ENTRADA DEL RETO 2

horas = 1:24;

generacion_solar = [0 0 0 0 0 5 9 13 17 21 24 25 ...
                    24 21 17 13 9 5 0 0 0 0 0 0];

generacion_eolica = [6 7 5 8 6 7 9 8 10 7 11 9 ...
                     8 10 7 12 9 8 7 6 8 7 5 6];

demanda = [3 2 4 3 2 6 7 8 9 8 9 10 ...
           9 8 7 8 9 15 15 15 15 4 3 2];

%% 2. PARAMETROS DE LA BATERIA

capacidad_bateria = 100;  % Capacidad en kWh
SOC = 50;                 % Estado de carga inicial (%)
SOC_minimo = 0;            % Limite minimo (%)
SOC_maximo = 100;          % Limite maximo (%)

%% 3. VECTORES PARA ALMACENAR RESULTADOS

generacion_total = zeros(1,24);
balance_energetico = zeros(1,24);
SOC_horario = zeros(1,24);

estado_escuela = strings(1,24);
estado_bombeo = strings(1,24);
estado_alumbrado = strings(1,24);

%% 4. CICLO DE CONTROL PARA LAS 24 HORAS

for h = 1:24

    % Calcular generacion hibrida total
    generacion_total(h) = generacion_solar(h) ...
                        + generacion_eolica(h);

    % Calcular balance energetico
    balance_energetico(h) = generacion_total(h) - demanda(h);

    % Actualizar estado de carga de la bateria
    if balance_energetico(h) >= 0

        % Escenario de superavit energetico
        excedente = balance_energetico(h);

        SOC_nuevo = SOC + ...
                    (excedente / capacidad_bateria) * 100;

    else

        % Escenario de deficit energetico
        faltante = abs(balance_energetico(h));

        SOC_nuevo = SOC - ...
                    (faltante / capacidad_bateria) * 100;

    end

    % Limitar el SOC entre 0 % y 100 %
    SOC = max(SOC_minimo, min(SOC_maximo, SOC_nuevo));

    % Control de cargas segun el SOC
    if SOC > 40

        % Ruta segura: todas las cargas activas
        estado_escuela(h) = "Activa";
        estado_bombeo(h) = "Activo";
        estado_alumbrado(h) = "Activo";

    elseif SOC > 20

        % Ruta de alerta: alumbrado desconectado
        estado_escuela(h) = "Activa";
        estado_bombeo(h) = "Activo";
        estado_alumbrado(h) = "Desconectado";

    else

        % Ruta de emergencia: bombeo y alumbrado desconectados
        estado_escuela(h) = "Activa";
        estado_bombeo(h) = "Desconectado";
        estado_alumbrado(h) = "Desconectado";

    end

    % Guardar SOC horario
    SOC_horario(h) = SOC;

end

%% 5. MOSTRAR REPORTE HORARIO EN LA CONSOLA

Reporte = table( ...
    horas', ...
    generacion_solar', ...
    generacion_eolica', ...
    generacion_total', ...
    demanda', ...
    balance_energetico', ...
    SOC_horario', ...
    estado_escuela', ...
    estado_bombeo', ...
    estado_alumbrado', ...
    'VariableNames', { ...
    'Hora', ...
    'Solar_kWh', ...
    'Eolica_kWh', ...
    'Generacion_Total_kWh', ...
    'Demanda_kWh', ...
    'Balance_kWh', ...
    'SOC_Porcentaje', ...
    'Escuela', ...
    'Bombeo_Agricola', ...
    'Alumbrado_Publico'});

disp('==============================================================');
disp(' REPORTE DEL SISTEMA INTELIGENTE DE GESTION ENERGETICA');
disp('==============================================================');

disp(Reporte);

%% 6. GRAFICA 1: GENERACION HIBRIDA Y DEMANDA

figure('Name', 'Generacion y demanda', ...
       'NumberTitle', 'off', ...
       'Color', 'w', ...
       'Position', [100 100 1000 500]);

plot(horas, generacion_total, '-o', ...
     'LineWidth', 2, 'MarkerSize', 6);
hold on;

plot(horas, demanda, '-s', ...
     'LineWidth', 2, 'MarkerSize', 6);

grid on;
box on;

title('Generacion Hibrida Total vs. Demanda', ...
      'FontSize', 14, 'FontWeight', 'bold');

xlabel('Hora del dia', 'FontSize', 12);
ylabel('Energia (kWh)', 'FontSize', 12);

xlim([1 24]);
xticks(1:24);

limite_generacion = max([generacion_total demanda]);
ylim([0 ceil(limite_generacion / 5) * 5 + 5]);

legend('Generacion solar + eolica', ...
       'Demanda de la comunidad', ...
       'Location', 'northwest');

set(gca, 'FontSize', 10);

%% 7. GRAFICA 2: ESTADO DE CARGA DE LA BATERIA

figure('Name', 'Estado de carga de la bateria', ...
       'NumberTitle', 'off', ...
       'Color', 'w', ...
       'Position', [120 120 1000 500]);

plot(horas, SOC_horario, '-o', ...
     'LineWidth', 2, 'MarkerSize', 6);
hold on;

yline(40, '--', 'LineWidth', 1.5);
yline(20, '--', 'LineWidth', 1.5);
yline(100, ':', 'LineWidth', 1.5);
yline(0, ':', 'LineWidth', 1.5);

grid on;
box on;

title('Estado de Carga de la Bateria (SOC)', ...
      'FontSize', 14, 'FontWeight', 'bold');

xlabel('Hora del dia', 'FontSize', 12);
ylabel('Estado de carga (%)', 'FontSize', 12);

xlim([1 24]);
xticks(1:24);
ylim([0 105]);
yticks(0:10:100);

legend('SOC de la bateria', ...
       'Umbral de alerta (40 %)', ...
       'Umbral de emergencia (20 %)', ...
       'SOC maximo (100 %)', ...
       'SOC minimo (0 %)', ...
       'Location', 'southoutside', ...
       'Orientation', 'horizontal');

set(gca, 'FontSize', 10);

%% 8. GRAFICA 3: BALANCE ENERGETICO HORARIO

figure('Name', 'Balance energetico', ...
       'NumberTitle', 'off', ...
       'Color', 'w', ...
       'Position', [140 140 1000 500]);

bar(horas, balance_energetico, 0.7);
hold on;

yline(0, 'k-', 'LineWidth', 1.5);

grid on;
box on;

title('Balance Energetico por Hora', ...
      'FontSize', 14, 'FontWeight', 'bold');

xlabel('Hora del dia', 'FontSize', 12);
ylabel('Balance energetico (kWh)', 'FontSize', 12);

xlim([0.5 24.5]);
xticks(1:24);

limite_balance = max(abs(balance_energetico));

if limite_balance > 0
    ylim([-limite_balance - 2, limite_balance + 2]);
else
    ylim([-2 2]);
end

legend('Balance energetico', ...
       'Balance cero', ...
       'Location', 'best');

set(gca, 'FontSize', 10);

%% 9. FINALIZACION

disp(' ');
disp('Simulacion finalizada correctamente.');
disp('Se procesaron las 24 horas del sistema.');
disp('Se generaron tres graficas independientes.');
