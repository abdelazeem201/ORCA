-----------------------------------------------------------------------
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ---- 
----                                                               ----  
----                                                               ----      
----  THIS LIBRARY IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN   ----
----  "AS IS" BASIS, WITH NO INTELLECUTAL PROPERTY                 ----
----  INDEMNIFICATION AND NO SUPPORT. ANY EXPRESS OR IMPLIED       ----
----  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED       ----
----  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR   ----
----  PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS    ----
----  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     ----
----  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      ----
----  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;     ----
----  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)     ----
----  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN    ----
----  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE    ----
----  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      ----
----  DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF         ----
----  SUCH DAMAGE.                                                 ---- 		
----                                                               ----  
----------------------------------------------------------------------- 


library IEEE;
use IEEE.std_logic_1164.all;

ENTITY SD_W_MUX IS
  PORT (
    blender_data      : IN  std_logic_vector(31 DOWNTO 0);
    pci_read_data     : IN  std_logic_vector(31 DOWNTO 0);
    risc_result_data  : IN  std_logic_vector(31 DOWNTO 0);
    sd_w_select       : IN  std_logic_vector(1 DOWNTO 0);
    sd_wfifo_data     : OUT std_logic_vector(31 DOWNTO 0)
  );

END SD_W_MUX;

ARCHITECTURE RTL OF SD_W_MUX IS
BEGIN

  WITH sd_w_select select
    sd_wfifo_data <= blender_data WHEN "01",
                     risc_result_data WHEN "10",
                     pci_read_data WHEN OTHERS;

END RTL;
